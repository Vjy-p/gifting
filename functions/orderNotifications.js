const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

/**
 * Lazy helper for Firestore database reference to avoid NO_APP errors before initializeApp()
 * @return {FirebaseFirestore.Firestore}
 */
function getDb() {
  return getFirestore();
}

/**
 * Status configurations for the order lifecycle:
 * 1. Order Placed
 * 2. Packed
 * 3. Picked
 * 4. Out for Delivery
 * 5. Delivered
 */
const ORDER_STATUS_CONFIG = {
  placed: {
    event: "placed",
    title: "Order Placed Successfully! 🎉",
    getBody: (orderNumber) =>
      `Thank you for your order${orderNumber ? ` #${orderNumber}` : ""}! We have received your order and are processing it.`,
    aliases: [
      "placed",
      "order_placed",
      "order placed",
      "created",
      "confirmed",
      "paid",
      "success",
      "new",
    ],
  },
  packed: {
    event: "packed",
    title: "Order Packed! 📦",
    getBody: (orderNumber) =>
      `Your order${orderNumber ? ` #${orderNumber}` : ""} has been carefully packed and is ready for pickup.`,
    aliases: ["packed", "order_packed", "order packed", "processing"],
  },
  picked: {
    event: "picked",
    title: "Order Picked Up! 🚚",
    getBody: (orderNumber) =>
      `Your order${orderNumber ? ` #${orderNumber}` : ""} has been picked up by our courier partner and is on its way.`,
    aliases: [
      "picked",
      "picked_up",
      "picked up",
      "order_picked",
      "order picked",
      "dispatched",
    ],
  },
  out_for_delivery: {
    event: "out_for_delivery",
    title: "Out for Delivery! 🛵",
    getBody: (orderNumber) =>
      `Your order${orderNumber ? ` #${orderNumber}` : ""} is out for delivery! Our delivery partner will arrive soon.`,
    aliases: [
      "out_for_delivery",
      "out for delivery",
      "out delivery",
      "out_delivery",
      "out-for-delivery",
    ],
  },
  delivered: {
    event: "delivered",
    title: "Order Delivered! 🎁",
    getBody: (orderNumber) =>
      `Your order${orderNumber ? ` #${orderNumber}` : ""} has been delivered. Thank you for choosing us!`,
    aliases: ["delivered", "order_delivered", "order delivered", "completed"],
  },
  cancelled: {
    event: "cancelled",
    title: "Order Cancelled ❌",
    getBody: (orderNumber) =>
      `Your order${orderNumber ? ` #${orderNumber}` : ""} has been cancelled.`,
    aliases: ["cancelled", "canceled", "order_cancelled"],
  },
};

/**
 * Normalizes any variation of status string into one of canonical keys
 * @param {string} status
 * @return {string|null}
 */
function normalizeStatus(status) {
  if (!status || typeof status !== "string") return null;
  const clean = status.trim().toLowerCase();

  for (const [canonical, config] of Object.entries(ORDER_STATUS_CONFIG)) {
    if (config.aliases.includes(clean)) {
      return canonical;
    }
  }
  return null;
}

/**
 * Backward-compatible helper for status details
 * @param {string} status
 * @param {string} referenceCode
 * @return {{title: string, body: string}}
 */
function getStatusNotificationDetails(status, referenceCode) {
  const canonical = normalizeStatus(status);
  const code = referenceCode || "";
  if (canonical && ORDER_STATUS_CONFIG[canonical]) {
    const config = ORDER_STATUS_CONFIG[canonical];
    return {
      title: config.title,
      body: config.getBody(code),
    };
  }
  return {
    title: "Order Update",
    body: `Your order ${code} status has been updated to ${status}.`,
  };
}

/**
 * Checks whether an FCM delivery error indicates that the token has expired or is invalid
 * @param {object} err
 * @return {boolean}
 */
function isTokenExpiredOrInvalid(err) {
  if (!err) return false;
  const code = err.code || "";
  const msg = (err.message || "").toLowerCase();
  return (
    code === "messaging/invalid-registration-token" ||
    code === "messaging/registration-token-not-registered" ||
    code === "messaging/mismatched-credential" ||
    msg.includes("not registered") ||
    msg.includes("invalid registration token") ||
    msg.includes("registration token is not valid") ||
    msg.includes("token is not valid") ||
    msg.includes("registration-token-not-registered") ||
    msg.includes("mismatched-credential")
  );
}

/**
 * Collects ONLY the active FCM device token for a user from:
 * 1. profiles/{userId} document (primary source of truth: single active fcm_token)
 * 2. Order document fallback (fcm_token) for guest or in-flight checkouts
 * @param {string} userId
 * @param {object} orderData
 * @return {Promise<string[]>}
 */
async function getUserTokens(userId, orderData) {
  const tokens = new Set();
  const db = getDb();

  // 1. Check 'profiles' collection for the single active token
  if (userId) {
    try {
      const profileDoc = await db.collection("profiles").doc(userId).get();
      if (profileDoc.exists) {
        const data = profileDoc.data() || {};
        // Primary: active fcm_token
        if (typeof data.fcm_token === "string" && data.fcm_token.trim()) {
          tokens.add(data.fcm_token.trim());
        } else if (typeof data.fcmToken === "string" && data.fcmToken.trim()) {
          tokens.add(data.fcmToken.trim());
        } else if (Array.isArray(data.fcm_tokens) && data.fcm_tokens.length > 0) {
          // Fallback: take only the most recent active token
          const last = data.fcm_tokens[data.fcm_tokens.length - 1];
          if (typeof last === "string" && last.trim()) {
            tokens.add(last.trim());
          }
        }
      }
    } catch (err) {
      logger.warn(`Error reading profile active token for ${userId}:`, err.message);
    }
  }

  // 2. If no active token found on profile, check order document as fallback
  if (tokens.size === 0 && orderData) {
    if (typeof orderData.fcm_token === "string" && orderData.fcm_token.trim()) {
      tokens.add(orderData.fcm_token.trim());
    } else if (typeof orderData.fcmToken === "string" && orderData.fcmToken.trim()) {
      tokens.add(orderData.fcmToken.trim());
    }
  }

  return Array.from(tokens);
}

/**
 * Removes expired/invalid/unregistered tokens from the user profile document and subcollection
 * @param {string} userId
 * @param {string[]} invalidTokens
 */
async function cleanInvalidTokens(userId, invalidTokens) {
  if (!userId || !invalidTokens || !invalidTokens.length) return;
  const db = getDb();
  try {
    const profileRef = db.collection("profiles").doc(userId);
    const docSnap = await profileRef.get();
    if (docSnap.exists) {
      const data = docSnap.data() || {};
      const updates = {
        fcm_tokens: FieldValue.arrayRemove(...invalidTokens),
        fcmTokens: FieldValue.arrayRemove(...invalidTokens),
      };

      // If the primary active fcm_token is one of the expired/invalid tokens, delete it!
      if (invalidTokens.includes(data.fcm_token)) {
        updates.fcm_token = FieldValue.delete();
        updates.fcm_token_updated_at = FieldValue.delete();
      }
      if (invalidTokens.includes(data.fcmToken)) {
        updates.fcmToken = FieldValue.delete();
      }
      await profileRef.update(updates).catch(() => {});
    }

    // Clean up from fcm_tokens subcollection
    for (const token of invalidTokens) {
      // 1. Delete by doc ID if token was doc ID
      await profileRef.collection("fcm_tokens").doc(token).delete().catch(() => {});

      // 2. Delete by token field query
      const snap = await profileRef
        .collection("fcm_tokens")
        .where("token", "==", token)
        .get()
        .catch(() => null);
      if (snap && !snap.empty) {
        snap.forEach((doc) => doc.ref.delete().catch(() => {}));
      }
    }

    logger.info(
      `Cleaned ${invalidTokens.length} expired/invalid FCM token(s) for user ${userId}`,
    );
  } catch (err) {
    logger.warn(`Could not remove invalid tokens for user ${userId}:`, err.message);
  }
}

/**
 * Core function to send FCM push notification and record notification history
 * @param {object} params
 * @return {Promise<object>}
 */
async function sendPushNotification({
  orderId,
  orderData,
  canonicalStatus,
  customTitle,
  customBody,
}) {
  const db = getDb();
  const config = ORDER_STATUS_CONFIG[canonicalStatus];
  if (!config) {
    return { success: false, reason: `Unknown canonical status: ${canonicalStatus}` };
  }

  const orderNumber =
    orderData.order_number ||
    orderData.orderNumber ||
    orderData.order_id ||
    orderData.orderId ||
    orderId;

  const userId =
    orderData.user_id ||
    orderData.userId ||
    orderData.uid ||
    "";

  const title = customTitle || config.title;
  const body = customBody || config.getBody(orderNumber);

  const payloadData = {
    order_id: String(orderId),
    order_number: String(orderNumber),
    status: String(canonicalStatus),
    event_type: "order_status_update",
    click_action: "FLUTTER_NOTIFICATION_CLICK",
    timestamp: new Date().toISOString(),
  };

  const tokens = await getUserTokens(userId, orderData);
  let sentCount = 0;
  let failedCount = 0;

  // 1. Send via Multicast to all registered device tokens
  if (tokens.length > 0) {
    const multicastMessage = {
      tokens,
      notification: {
        title,
        body,
      },
      data: payloadData,
      android: {
        priority: "high",
        notification: {
          channelId: "order_updates",
          sound: "default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await getMessaging().sendEachForMulticast(multicastMessage);
      sentCount += response.successCount;
      failedCount += response.failureCount;

      logger.info(
        `FCM sent for order ${orderId} (${canonicalStatus}): ${response.successCount} success, ${response.failureCount} failed`,
      );

      // Identify invalid/expired tokens for cleanup
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error) {
          if (isTokenExpiredOrInvalid(resp.error)) {
            invalidTokens.push(tokens[idx]);
          }
        }
      });

      if (invalidTokens.length > 0 && userId) {
        cleanInvalidTokens(userId, invalidTokens).catch((e) =>
          logger.warn("Failed to clean invalid tokens:", e.message),
        );
      }
    } catch (err) {
      logger.error(`Error sending multicast FCM for order ${orderId}:`, err);
    }
  } else {
    logger.info(
      `No device tokens found for user ${userId || "unknown"} on order ${orderId}. Will attempt topic delivery.`,
    );
  }

  // 2. Also send to Topic 'user_<userId>' as fallback/multi-device guarantee
  if (userId) {
    try {
      const topicMessage = {
        topic: `user_${userId}`,
        notification: {
          title,
          body,
        },
        data: payloadData,
        android: {
          priority: "high",
          notification: {
            channelId: "order_updates",
            sound: "default",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      await getMessaging().send(topicMessage);
      logger.info(`FCM sent to topic 'user_${userId}' for order ${orderId}`);
    } catch (err) {
      logger.debug(`Topic notification note (user_${userId}):`, err.message);
    }
  }

  // 3. Record Notification in Firestore (In-app notification history & Idempotency)
  const notificationRecord = {
    order_id: orderId,
    order_number: orderNumber,
    status: canonicalStatus,
    title,
    body,
    read: false,
    created_at: FieldValue.serverTimestamp(),
    data: payloadData,
  };

  const batch = db.batch();

  // Save to user notifications if user ID is known
  if (userId) {
    const userNotifRef = db
      .collection("profiles")
      .doc(userId)
      .collection("notifications")
      .doc();
    batch.set(userNotifRef, notificationRecord);
  }

  // Save to order notifications subcollection
  const orderNotifRef = db
    .collection("orders")
    .doc(orderId)
    .collection("notifications")
    .doc();
  batch.set(orderNotifRef, notificationRecord);

  // Mark order document with notified status to prevent duplicate notifications
  const orderRef = db.collection("orders").doc(orderId);
  batch.set(
    orderRef,
    {
      last_notified_status: canonicalStatus,
      last_notified_at: FieldValue.serverTimestamp(),
      notified_statuses: FieldValue.arrayUnion(canonicalStatus),
    },
    { merge: true },
  );

  await batch.commit();

  return {
    success: true,
    orderId,
    orderNumber,
    status: canonicalStatus,
    title,
    body,
    sentCount,
    failedCount,
  };
}

/**
 * Firestore Trigger: Listens to all order creates and updates.
 * Sends push notification when order is:
 * - placed (created / confirmed / paid)
 * - packed
 * - picked
 * - out_for_delivery
 * - delivered
 */
const onOrderStatusWritten = onDocumentWritten(
  {
    document: "orders/{orderId}",
    region: "asia-south1",
  },
  async (event) => {
    const orderId = event.params.orderId;

    // Document was deleted
    if (!event.data.after.exists) {
      logger.info(`Order ${orderId} was deleted, skipping notification.`);
      return null;
    }

    const beforeData = event.data.before.exists ? event.data.before.data() : null;
    const afterData = event.data.after.data();

    const afterRawStatus =
      afterData.order_status || afterData.status || afterData.orderStatus;
    const canonicalAfterStatus = normalizeStatus(afterRawStatus);

    if (!canonicalAfterStatus) {
      logger.info(
        `Order ${orderId} status "${afterRawStatus}" is not a tracked lifecycle state. Skipping.`,
      );
      return null;
    }

    // If this is an update, verify that status actually changed
    if (beforeData) {
      const beforeRawStatus =
        beforeData.order_status || beforeData.status || beforeData.orderStatus;
      const canonicalBeforeStatus = normalizeStatus(beforeRawStatus);

      if (canonicalBeforeStatus === canonicalAfterStatus) {
        // Status didn't change (e.g. metadata or payment details updated)
        return null;
      }
    }

    // Check idempotency: avoid sending duplicate push for the same status
    const notifiedStatuses = afterData.notified_statuses || [];
    if (notifiedStatuses.includes(canonicalAfterStatus)) {
      logger.info(
        `Order ${orderId} already notified for status "${canonicalAfterStatus}". Skipping duplicate.`,
      );
      return null;
    }

    logger.info(
      `Triggering push notification for order ${orderId}: transitioning to "${canonicalAfterStatus}".`,
    );

    return await sendPushNotification({
      orderId,
      orderData: afterData,
      canonicalStatus: canonicalAfterStatus,
    });
  },
);

/**
 * Callable Function: updateOrderStatus
 * Allows backend / admin dashboard to update order status,
 * which will update Firestore and trigger the push notification.
 */
const updateOrderStatus = onCall(async (req) => {
  if (!req.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const { orderId, status, trackingId, deliveryPartner, notes } = req.data || {};
  if (!orderId || !status) {
    throw new HttpsError("invalid-argument", "orderId and status are required");
  }

  const canonical = normalizeStatus(status);
  if (!canonical) {
    throw new HttpsError(
      "invalid-argument",
      `Invalid status "${status}". Allowed: placed, packed, picked, out_for_delivery, delivered, cancelled`,
    );
  }

  const db = getDb();
  const orderRef = db.collection("orders").doc(orderId);
  const snap = await orderRef.get();

  if (!snap.exists) {
    throw new HttpsError("not-found", `Order ${orderId} does not exist`);
  }

  const updateData = {
    order_status: canonical,
    status: canonical,
    updated_at: FieldValue.serverTimestamp(),
  };
  if (trackingId) updateData.tracking_id = trackingId;
  if (deliveryPartner) updateData.delivery_partner = deliveryPartner;
  if (notes) updateData.notes = notes;

  await orderRef.update(updateData);

  return {
    success: true,
    orderId,
    status: canonical,
    message: `Order ${orderId} updated to ${canonical}`,
  };
});

/**
 * Callable Function: sendOrderNotificationManual
 * Allows admin to manually trigger or re-send notification for an order.
 */
const sendOrderNotificationManual = onCall(async (req) => {
  if (!req.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const { orderId, status, title, body } = req.data || {};
  if (!orderId) {
    throw new HttpsError("invalid-argument", "orderId is required");
  }

  const db = getDb();
  const snap = await db.collection("orders").doc(orderId).get();
  if (!snap.exists) {
    throw new HttpsError("not-found", `Order ${orderId} does not exist`);
  }

  const orderData = snap.data();
  const canonicalStatus = normalizeStatus(
    status || orderData.order_status || orderData.status,
  );

  if (!canonicalStatus) {
    throw new HttpsError(
      "invalid-argument",
      `Unknown status "${status}". Allowed: placed, packed, picked, out_for_delivery, delivered, cancelled`,
    );
  }

  return await sendPushNotification({
    orderId,
    orderData,
    canonicalStatus,
    customTitle: title,
    customBody: body,
  });
});

/**
 * HTTP Endpoint: testOrderStatusNotification
 * For testing and verification via cURL / Postman / browser:
 * GET or POST /testOrderStatusNotification?orderId=...&status=packed
 */
const testOrderStatusNotification = onRequest(async (req, res) => {
  const orderId = req.query.orderId || req.body?.orderId;
  const status = req.query.status || req.body?.status || "placed";

  if (!orderId) {
    return res.status(400).json({
      error: "Missing orderId. Provide ?orderId=... in query or JSON body",
    });
  }

  const canonicalStatus = normalizeStatus(status);
  if (!canonicalStatus) {
    return res.status(400).json({
      error: `Invalid status "${status}". Allowed: placed, packed, picked, out_for_delivery, delivered, cancelled`,
    });
  }

  const db = getDb();
  const snap = await db.collection("orders").doc(orderId).get();
  if (!snap.exists) {
    return res.status(404).json({ error: `Order ${orderId} not found in Firestore` });
  }

  try {
    const result = await sendPushNotification({
      orderId,
      orderData: snap.data(),
      canonicalStatus,
    });
    return res.status(200).json(result);
  } catch (err) {
    logger.error("Error in testOrderStatusNotification:", err);
    return res.status(500).json({ error: err.message });
  }
});

module.exports = {
  ORDER_STATUS_CONFIG,
  normalizeStatus,
  getStatusNotificationDetails,
  sendPushNotification,
  onOrderStatusWritten,
  updateOrderStatus,
  sendOrderNotificationManual,
  testOrderStatusNotification,
  getUserTokens,
  cleanInvalidTokens,
  isTokenExpiredOrInvalid,
};
