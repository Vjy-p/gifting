import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/features/notifications/controllers/notification_controller.dart';
import 'package:gifting/features/notifications/models/in_app_notification_model.dart';
import 'package:gifting/firebase_options.dart';
import 'package:hive/hive.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log(
      '[FCM Background] Received message: ${message.messageId}, data: ${message.data}',
    );
  } catch (e) {
    log('[FCM Background] Error in background handler: $e');
  }
}

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _orderChannel =
      AndroidNotificationChannel(
        'order_updates',
        'Order Updates',
        description: 'Real-time order lifecycle status notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  static bool _initialized = false;

  /// Initializes push notification handling, flutter_local_notifications, and listeners.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Initialize flutter_local_notifications for foreground & system notifications
      await _initializeLocalNotifications();

      // 2. Set Firebase background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Request permissions for iOS and Android 13+
      await requestPermission();

      // 4. Configure foreground presentation options on iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Foreground FCM message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        log(
          '[FCM Foreground] Title: ${message.notification?.title}, Body: ${message.notification?.body}',
        );
        log('[FCM Foreground] Data: ${message.data}');

        final title =
            message.notification?.title ??
            message.data['title']?.toString() ??
            'Order Update';
        final body =
            message.notification?.body ??
            message.data['body']?.toString() ??
            'Your order status has been updated.';

        final orderId = message.data['order_id']?.toString() ?? '';
        final orderNumber = message.data['order_number']?.toString() ?? '';
        final status = message.data['status']?.toString() ?? 'placed';

        // 5a. Show native heads-up/tray notification using flutter_local_notifications
        await showLocalNotification(
          id: message.hashCode,
          title: title,
          body: body,
          payload: jsonEncode(message.data),
          orderNumber: orderNumber.isNotEmpty ? orderNumber : null,
          status: status,
        );

        // 5b. Show elegant in-app floating banner if user is inside the app
        final inAppNotification = InAppNotificationModel(
          id:
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          orderId: orderId,
          orderNumber: orderNumber,
          status: status,
          title: title,
          body: body,
          isRead: false,
          createdAt: DateTime.now(),
          data: message.data,
        );

        if (Get.isRegistered<NotificationController>()) {
          NotificationController.to.showInAppBanner(inAppNotification);
        }
      });

      // 6. Message clicked from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('[FCM onMessageOpenedApp] Notification opened: ${message.data}');
        _handleNotificationNavigation(message.data);
      });

      // 7. App opened from terminated state via notification click
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        log(
          '[FCM InitialMessage] Opened app from terminated: ${initialMessage.data}',
        );
        _handleNotificationNavigation(initialMessage.data);
      }

      // 8. Listen for token refreshes (when FCM token expires, rotates, or invalidates)
      // ignore: deprecated_member_use
      _messaging.onTokenRefresh.listen((newToken) async {
        log('[FCM Token Refreshed / Old Token Expired]: $newToken');
        final previousToken = cachedActiveToken;
        final user = _auth.currentUser;
        if (user != null) {
          if (previousToken != null && previousToken != newToken) {
            await _removeSpecificToken(user.uid, previousToken);
          }
          await saveTokenForUser(user.uid, token: newToken);
        } else {
          await _setCachedActiveToken(newToken);
        }
      });

      // 9. If user is currently signed in, ensure their token is synced
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await saveTokenForUser(currentUser.uid);
      }
    } catch (e, stackTrace) {
      log('[NotificationService] Initialization error: $e $stackTrace');
    }
  }

  /// Sets up flutter_local_notifications plugins, channels, and click callbacks
  static Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel on Android (required for Android 8.0+)
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_orderChannel);
      }
      log('[NotificationService] flutter_local_notifications initialized');
    } catch (e, stackTrace) {
      log(
        '[NotificationService] Error initializing flutter_local_notifications: $e $stackTrace',
      );
    }
  }

  /// Triggers a local notification on the device
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? orderNumber,
    String? status,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _orderChannel.id,
        _orderChannel.name,
        channelDescription: _orderChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: orderNumber != null && orderNumber.isNotEmpty
              ? 'Order #$orderNumber'
              : 'Order Update',
        ),
        playSound: true,
        enableVibration: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
      log('[NotificationService] Local notification displayed ($id)');
    } catch (e) {
      log('[NotificationService] Error showing local notification: $e');
    }
  }

  /// Callback when user taps a flutter_local_notifications notification
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      log(
        '[NotificationService] Local notification response: ${response.payload}',
      );
      if (response.payload != null && response.payload!.isNotEmpty) {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } else {
        _handleNotificationNavigation({});
      }
    } catch (e) {
      log('[NotificationService] Error handling local notification tap: $e');
      _handleNotificationNavigation({});
    }
  }

  /// Requests user permission for notifications
  static Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    log(
      '[FCM Permission] Authorization status: ${settings.authorizationStatus}',
    );
    return settings;
  }

  static const String _activeFcmTokenKey = 'active_fcm_token';
  static String? _memoryToken;

  /// Gets the locally cached active FCM token
  static String? get cachedActiveToken {
    try {
      if (Hive.isBoxOpen(HiveService.settingsBoxName)) {
        final saved =
            HiveService.settingsBox.get(_activeFcmTokenKey) as String?;
        if (saved != null && saved.isNotEmpty) return saved;
      }
    } catch (_) {}
    return _memoryToken;
  }

  /// Persists the active token locally
  static Future<void> _setCachedActiveToken(String? token) async {
    _memoryToken = token;
    try {
      if (Hive.isBoxOpen(HiveService.settingsBoxName)) {
        if (token == null || token.isEmpty) {
          await HiveService.settingsBox.delete(_activeFcmTokenKey);
        } else {
          await HiveService.settingsBox.put(_activeFcmTokenKey, token);
        }
      }
    } catch (e) {
      log('[NotificationService] Error saving cached active token: $e');
    }
  }

  /// Gets current FCM token
  static Future<String?> getToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _setCachedActiveToken(token);
      }
      log('[FCM Token]: $token');
      return token;
    } catch (e) {
      log('[NotificationService] Error getting token: $e');
      return null;
    }
  }

  /// Saves the active FCM device token in the user's Firestore profile and subscribes to user topic.
  /// Removes any expired or previous tokens to ensure ONLY the single active token is stored.
  static Future<void> saveTokenForUser(String userId, {String? token}) async {
    try {
      final fcmToken = token ?? await getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      final previousToken = cachedActiveToken;

      // 1. If token changed (old expired/refreshed), clean up old token from Firestore
      if (previousToken != null && previousToken != fcmToken) {
        await _removeSpecificToken(userId, previousToken);
      }

      final now = DateTime.now().toIso8601String();

      // 2. Update user profile document in Firestore: store ONLY the single active token
      await _firestore.collection('profiles').doc(userId).set({
        'fcm_token': fcmToken,
        'fcm_tokens': [fcmToken], // Only the single active token
        'fcm_token_updated_at': now,
        'updated_at': now,
      }, SetOptions(merge: true));

      // 3. Keep only the active token in the fcm_tokens subcollection
      final subcollectionRef = _firestore
          .collection('profiles')
          .doc(userId)
          .collection('fcm_tokens');

      await subcollectionRef.doc(fcmToken).set({
        'token': fcmToken,
        'platform': defaultTargetPlatform.name,
        'is_active': true,
        'updated_at': now,
      }, SetOptions(merge: true));

      // Query subcollection and delete any obsolete/expired token documents
      final existingDocs = await subcollectionRef.get();
      for (final doc in existingDocs.docs) {
        if (doc.id != fcmToken) {
          await doc.reference.delete().catchError((_) {});
        }
      }

      // 4. Subscribe user to their personal topic for lifecycle push broadcasts
      if (GetPlatform.isAndroid) {
        await _messaging.subscribeToTopic('user_$userId');
        await _setCachedActiveToken(fcmToken);
      }

      log(
        '[NotificationService] Active token ($fcmToken) saved & subscribed to topic user_$userId',
      );
    } catch (e, stackTrace) {
      log('[NotificationService] Error saving token for user: $e $stackTrace');
    }
  }

  /// Removes a specific expired/old token from the user profile and subcollection
  static Future<void> _removeSpecificToken(
    String userId,
    String tokenToRemove,
  ) async {
    try {
      if (tokenToRemove.isEmpty) return;

      final profileRef = _firestore.collection('profiles').doc(userId);
      final profileSnap = await profileRef.get();
      if (profileSnap.exists) {
        final data = profileSnap.data() ?? {};
        final currentToken = data['fcm_token']?.toString();

        final updates = <String, dynamic>{
          'fcm_tokens': FieldValue.arrayRemove([tokenToRemove]),
        };

        if (currentToken == tokenToRemove) {
          updates['fcm_token'] = FieldValue.delete();
          updates['fcm_token_updated_at'] = FieldValue.delete();
        }

        await profileRef.update(updates).catchError((_) {});
      }

      final subRef = profileRef.collection('fcm_tokens');
      await subRef.doc(tokenToRemove).delete().catchError((_) {});
      final matches = await subRef
          .where('token', isEqualTo: tokenToRemove)
          .get();
      for (final doc in matches.docs) {
        await doc.reference.delete().catchError((_) {});
      }

      log(
        '[NotificationService] Removed expired token: $tokenToRemove for user $userId',
      );
    } catch (e) {
      log('[NotificationService] Error removing specific token: $e');
    }
  }

  /// Removes active token, deletes token instance, and unsubscribes from topics on logout
  static Future<void> removeTokenOnLogout(String userId) async {
    try {
      final activeToken = cachedActiveToken ?? await getToken();

      // 1. Delete fcm_token from profile document
      await _firestore
          .collection('profiles')
          .doc(userId)
          .update({
            'fcm_token': FieldValue.delete(),
            'fcm_tokens': <String>[],
            'fcm_token_updated_at': FieldValue.delete(),
          })
          .catchError((e) {
            log(
              '[NotificationService] Profile document update error on logout: $e',
            );
          });

      // 2. Remove all tokens from fcm_tokens subcollection
      final subSnap = await _firestore
          .collection('profiles')
          .doc(userId)
          .collection('fcm_tokens')
          .get();
      for (final doc in subSnap.docs) {
        await doc.reference.delete().catchError((_) {});
      }

      // 3. Unsubscribe from user personal topic
      await _messaging.unsubscribeFromTopic('user_$userId');

      // 4. Invalidate the FCM token on device so it expires immediately
      try {
        await _messaging.deleteToken();
      } catch (e) {
        log('[NotificationService] Error deleting token from device: $e');
      }

      // 5. Clear cached token
      await _setCachedActiveToken(null);
      log(
        '[NotificationService] Active token removed on logout and invalidated',
      );
    } catch (e) {
      log('[NotificationService] Error cleaning token on logout: $e');
    }
  }

  /// Forces expiration of current token and generates a new active FCM token
  static Future<String?> refreshActiveToken([String? userId]) async {
    try {
      final targetUserId = userId ?? _auth.currentUser?.uid;
      final oldToken = cachedActiveToken;

      if (targetUserId != null && oldToken != null) {
        await _removeSpecificToken(targetUserId, oldToken);
      }

      // Invalidate current token on device
      await _messaging.deleteToken();
      await _setCachedActiveToken(null);

      // Generate a fresh active token
      final newToken = await getToken();
      if (newToken != null && newToken.isNotEmpty) {
        if (targetUserId != null) {
          await saveTokenForUser(targetUserId, token: newToken);
        } else {
          await _setCachedActiveToken(newToken);
        }
      }
      return newToken;
    } catch (e) {
      log('[NotificationService] Error refreshing active token: $e');
      return null;
    }
  }

  /// Navigates to appropriate screen when a notification is clicked
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    try {
      final orderId = data['order_id']?.toString();
      final status = data['status']?.toString();

      log(
        '[NotificationService] Navigating for order: $orderId, status: $status',
      );

      // If specific order is targeted, go to live order tracking details
      if (orderId != null && orderId.isNotEmpty) {
        Get.toNamed(AppRoutes.orderDetails, arguments: orderId);
      } else {
        if (Get.currentRoute != AppRoutes.notifications) {
          Get.toNamed(AppRoutes.notifications);
        }
      }
    } catch (e) {
      log('[NotificationService] Error navigating on notification tap: $e');
    }
  }
}
