import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/order/models/order_model.dart';

class OrderController extends GetxController {
  static OrderController get to => Get.find<OrderController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// Active filter key matching OrderStatus.allFilters ('All', 'New', 'Processing', etc.)
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToAuth();
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  void _listenToAuth() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        startListeningToOrders(user.uid);
      } else {
        _ordersSubscription?.cancel();
        orders.clear();
        filteredOrders.clear();
      }
    });

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      startListeningToOrders(currentUser.uid);
    }
  }

  /// Real-time stream of all orders placed by the current user
  void startListeningToOrders(String userId) {
    _ordersSubscription?.cancel();
    isLoading.value = true;
    error.value = '';

    try {
      _ordersSubscription = _firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .snapshots()
          .listen(
            (snapshot) {
              final list = snapshot.docs
                  .map((doc) => OrderModel.fromFirestore(doc))
                  .toList();

              // Sort by created_at descending (newest first)
              list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              orders.assignAll(list);
              _applyFilters();
              isLoading.value = false;
            },
            onError: (err) {
              log('[OrderController] Firestore stream error: $err');
              error.value = err.toString();
              isLoading.value = false;
            },
          );
    } catch (e) {
      log('[OrderController] Error subscribing to orders: $e');
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  /// Sets filter tab from OrderStatus.allFilters
  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  /// Filters by search query (order ID or item name)
  void setSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var result = List<OrderModel>.from(orders);

    final f = selectedFilter.value.trim().toLowerCase();
    if (f != 'all' && f.isNotEmpty) {
      if (f == 'active') {
        result = result.where((o) => o.isActive).toList();
      } else if (f == 'delivered') {
        result = result.where((o) => o.isDelivered).toList();
      } else if (f == 'cancelled') {
        result = result.where((o) => o.isCancelled).toList();
      } else {
        final targetStatus = OrderStatus.fromString(selectedFilter.value);
        result = result.where((o) => o.status == targetStatus).toList();
      }
    }

    // Apply search query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((o) {
        final matchesId =
            o.orderNumber.toLowerCase().contains(query) ||
            o.id.toLowerCase().contains(query);
        final matchesItem = o.items.any(
          (i) => i.name.toLowerCase().contains(query),
        );
        return matchesId || matchesItem;
      }).toList();
    }

    filteredOrders.assignAll(result);
  }

  /// Streams a single order for live tracking in OrderDetailsScreen
  Stream<OrderModel?> streamOrder(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return OrderModel.fromFirestore(doc);
    });
  }

  /// Cancels an order if eligible (only when status == OrderStatus.newOrder)
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      final docRef = _firestore.collection('orders').doc(orderId);
      final snap = await docRef.get();

      if (!snap.exists) {
        customToast(title: 'Error', text: 'Order not found.');
        return false;
      }

      final data = snap.data()!;
      final currentStatus = OrderStatus.fromString(
        (data['status'] ?? data['order_status'])?.toString(),
      );

      if (!currentStatus.canCancel) {
        customToast(
          title: 'Cannot Cancel',
          text:
              'This order is already being processed and cannot be cancelled.',
        );
        return false;
      }

      await docRef.update({
        'order_status': OrderStatus.cancelled.value,
        'status': OrderStatus.cancelled.value,
        'status_note': reason ?? 'Cancelled by customer',
        'cancelled_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      customToast(
        title: 'Order Cancelled',
        text: 'Your order has been cancelled.',
      );
      return true;
    } catch (e) {
      log('[OrderController] Error cancelling order: $e');
      customToast(title: 'Error', text: 'Failed to cancel order: $e');
      return false;
    }
  }
}
