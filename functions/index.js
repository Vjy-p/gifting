const {
  onCall,
  onRequest,
  HttpsError,
} = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const Razorpay = require("razorpay");
const crypto = require("crypto");

initializeApp();
const db = getFirestore();

const KEY_ID = defineSecret("RAZORPAY_KEY_ID");
const KEY_SECRET = defineSecret("RAZORPAY_KEY_SECRET");
const WEBHOOK_SECRET = defineSecret("RAZORPAY_WEBHOOK_SECRET");

exports.createOrder = onCall({ secrets: [KEY_ID, KEY_SECRET] }, async (req) => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Login required");

  const { productId } = req.data;
  const snap = await db.collection("products").doc(productId).get();
  if (!snap.exists) throw new HttpsError("not-found", "Product not found");

  const amountPaise = snap.data().min_price * 100;

  const rzp = new Razorpay({
    key_id: KEY_ID.value(),
    key_secret: KEY_SECRET.value(),
  });
  const order = await rzp.orders.create({
    amount: amountPaise,
    currency: "INR",
    receipt: `rcpt_${Date.now()}`,
  });

  await db.collection("orders").doc(order.id).set({
    uid: req.auth.uid,
    productId,
    amount: amountPaise,
    status: "created",
    createdAt: FieldValue.serverTimestamp(),
  });

  return { orderId: order.id, amount: order.amount, keyId: KEY_ID.value() };
});

exports.verifyPayment = onCall({ secrets: [KEY_SECRET] }, async (req) => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Login required");

  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } =
    req.data;
  const expected = crypto
    .createHmac("sha256", KEY_SECRET.value())
    .update(`${razorpay_order_id}|${razorpay_payment_id}`)
    .digest("hex");

  if (expected !== razorpay_signature) {
    throw new HttpsError("permission-denied", "Invalid signature");
  }

  await db.collection("orders").doc(razorpay_order_id).update({
    status: "paid",
    paymentId: razorpay_payment_id,
  });
  return { success: true };
});

exports.razorpayWebhook = onRequest(
  { secrets: [WEBHOOK_SECRET] },
  async (req, res) => {
    const signature = req.get("X-Razorpay-Signature");
    const expected = crypto
      .createHmac("sha256", WEBHOOK_SECRET.value())
      .update(req.rawBody)
      .digest("hex");

    if (signature !== expected) {
      return res.status(400).send("Invalid signature");
    }

    if (req.body.event === "payment.captured") {
      const p = req.body.payload.payment.entity;
      await db
        .collection("orders")
        .doc(p.order_id)
        .set({ status: "paid", paymentId: p.id }, { merge: true });
    }
    res.status(200).send("ok");
  },
);

const {
  onOrderStatusWritten,
  updateOrderStatus,
  sendOrderNotificationManual,
  testOrderStatusNotification,
} = require("./orderNotifications");

// Order Lifecycle Push Notification Functions
exports.onOrderStatusWritten = onOrderStatusWritten;
exports.updateOrderStatus = updateOrderStatus;
exports.sendOrderNotificationManual = sendOrderNotificationManual;
exports.testOrderStatusNotification = testOrderStatusNotification;
