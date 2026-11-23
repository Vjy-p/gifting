import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/features/notifications/models/in_app_notification_model.dart';
import 'package:gifting/features/notifications/views/widgets/in_app_banner_widget.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find<NotificationController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<InAppNotificationModel> notifications =
      <InAppNotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  void _listenToAuthChanges() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        startListeningToNotifications(user.uid);
      } else {
        stopListeningToNotifications();
        notifications.clear();
        unreadCount.value = 0;
      }
    });

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      startListeningToNotifications(currentUser.uid);
    }
  }

  /// Starts real-time Firestore stream for the current user's notifications
  void startListeningToNotifications(String userId) {
    _notificationSubscription?.cancel();
    isLoading.value = true;

    try {
      _notificationSubscription = _firestore
          .collection('profiles')
          .doc(userId)
          .collection('notifications')
          .orderBy('created_at', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              final items = snapshot.docs
                  .map((doc) => InAppNotificationModel.fromFirestore(doc))
                  .toList();

              notifications.assignAll(items);
              unreadCount.value = items.where((n) => !n.isRead).length;
              isLoading.value = false;
            },
            onError: (err) {
              log('[NotificationController] Firestore error: $err');
              isLoading.value = false;
            },
          );
    } catch (e) {
      log('[NotificationController] Error subscribing: $e');
      isLoading.value = false;
    }
  }

  void stopListeningToNotifications() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  /// Displays the rich in-app notification banner at the top of the screen
  void showInAppBanner(InAppNotificationModel notification) {
    if (Get.context == null) return;

    Get.rawSnackbar(
      messageText: InAppBannerWidget(
        notification: notification,
        onDismiss: () {
          if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        },
        onTap: () {
          if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
          markAsRead(notification.id);
          _navigateToOrderOrHistory(notification);
        },
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      duration: const Duration(seconds: 5),
      barBlur: 0,
      overlayBlur: 0,
    );
  }

  /// Helper to handle tap navigation from notification
  void _navigateToOrderOrHistory(InAppNotificationModel notification) {
    try {
      if (notification.orderId.isNotEmpty) {
        Get.toNamed(AppRoutes.orderDetails, arguments: notification.orderId);
      } else if (Get.currentRoute != AppRoutes.order) {
        Get.toNamed(AppRoutes.order);
      }
    } catch (e) {
      log('[NotificationController] Navigation error: $e');
    }
  }

  /// Marks a single notification as read
  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null || notificationId.isEmpty) return;

    try {
      await _firestore
          .collection('profiles')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      log('[NotificationController] Error markAsRead: $e');
    }
  }

  /// Marks all notifications for the current user as read
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final unreadDocs = await _firestore
          .collection('profiles')
          .doc(user.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      if (unreadDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
      unreadCount.value = 0;
    } catch (e) {
      log('[NotificationController] Error markAllAsRead: $e');
    }
  }

  /// Deletes a specific notification
  Future<void> deleteNotification(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null || notificationId.isEmpty) return;

    try {
      await _firestore
          .collection('profiles')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      notifications.removeWhere((n) => n.id == notificationId);
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      log('[NotificationController] Error deleteNotification: $e');
    }
  }

  /// Clears all notifications
  Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docs = await _firestore
          .collection('profiles')
          .doc(user.uid)
          .collection('notifications')
          .get();

      final batch = _firestore.batch();
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      log('[NotificationController] Error clearAll: $e');
    }
  }
}
