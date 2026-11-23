import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gifting/core/services/notification_service.dart';
import 'package:gifting/features/order/models/order_model.dart';
import 'package:gifting/features/payment/models/payment_model.dart';
import 'package:uuid/uuid.dart';

class PaymentServices {
  PaymentServices._internal({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _customFirestore = firestore,
      _customAuth = auth;

  static PaymentServices? _instance;

  factory PaymentServices({FirebaseFirestore? firestore, FirebaseAuth? auth}) {
    if (firestore != null || auth != null) {
      return PaymentServices._internal(firestore: firestore, auth: auth);
    }
    _instance ??= PaymentServices._internal();
    return _instance!;
  }

  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Verifies payment on Firestore and creates the corresponding order record in the 'orders' collection
  Future<dynamic> verifyPayment({
    required String currentDbPaymentId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      final updateData = <String, dynamic>{
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
        'status': 'captured',
        'paid_at': now,
        'updated_at': now,
      };

      final firestoreInstance = _firestore;
      if (firestoreInstance != null) {
        // 1. Update payment document
        await firestoreInstance
            .collection('payments')
            .doc(currentDbPaymentId)
            .set(updateData, SetOptions(merge: true));

        // 2. Fetch payment document details to construct the order
        final paymentDoc = await firestoreInstance
            .collection('payments')
            .doc(currentDbPaymentId)
            .get();
        final paymentData = paymentDoc.data() ?? {};

        final orderDocId =
            paymentData['order_id']?.toString() ??
            (orderId.isNotEmpty
                ? orderId
                : 'order_${DateTime.now().millisecondsSinceEpoch}');

        final items = paymentData['items'] as List? ?? [];
        final amountInPaise = (paymentData['amount'] as num?)?.toInt() ?? 0;
        final totalRupees = amountInPaise > 0 ? (amountInPaise / 100.0) : 0.0;

        final fcmToken = await NotificationService.getToken();

        final orderData = <String, dynamic>{
          'id': orderDocId,
          'order_id': orderDocId,
          'order_number': orderDocId,
          'user_id':
              paymentData['user_id'] ?? _auth?.currentUser?.uid ?? 'guest_user',
          'user_email':
              paymentData['user_email'] ?? _auth?.currentUser?.email ?? '',
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
          'items': items,
          'item_count': items.length,
          'total_amount': totalRupees,
          'amount_in_paise': amountInPaise,
          'currency': paymentData['currency'] ?? 'INR',
          'payment_id': paymentId,
          'payment_db_id': currentDbPaymentId,
          'payment_signature': signature,
          'payment_status': 'paid',
          'order_status': 'confirmed',
          'created_at': paymentData['created_at'] ?? now,
          'paid_at': now,
          'updated_at': now,
        };

        // 3. Create confirmed order in 'orders' collection
        await firestoreInstance
            .collection('orders')
            .doc(orderDocId)
            .set(orderData, SetOptions(merge: true));

        log(
          '[PaymentServices] Payment verified ($currentDbPaymentId) & Order created ($orderDocId) in Firestore',
        );

        return {'success': true, 'payment': updateData, 'order': orderData};
      }

      log('[PaymentServices] Payment verified (local): $currentDbPaymentId');
      return {'success': true, 'payment': updateData};
    } catch (e, stackTrace) {
      log('[PaymentServices] Error in verifyPayment: $e $stackTrace');
      return {'error': e.toString()};
    }
  }

  /// Updates payment document in 'payments' collection when payment fails or is cancelled
  Future<dynamic> recordPaymentFailure({
    required String currentDbPaymentId,
    required String errorCode,
    required String errorDescription,
    String? errorReason,
    bool isCancelled = false,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      final updateData = <String, dynamic>{
        'status': isCancelled ? 'cancelled' : 'failed',
        'error_code': errorCode,
        'error_description': errorDescription,
        if (errorReason != null && errorReason.isNotEmpty)
          'error_reason': errorReason,
        'failed_at': now,
        'updated_at': now,
      };

      final firestoreInstance = _firestore;
      if (firestoreInstance != null) {
        await firestoreInstance
            .collection('payments')
            .doc(currentDbPaymentId)
            .set(updateData, SetOptions(merge: true));

        log(
          '[PaymentServices] Payment failure recorded in Firestore: $currentDbPaymentId (status: ${updateData['status']})',
        );
      }

      return {'success': true, 'payment': updateData};
    } catch (e, stackTrace) {
      log('[PaymentServices] Error recording payment failure: $e $stackTrace');
      return {'error': e.toString()};
    }
  }

  /// Initiates payment order record in 'payments' collection
  Future<Map<String, dynamic>?> getOrderID({
    String? id,
    int? amountInPaise,
    String? currency,
    List<Map<String, dynamic>>? items,
    String? userEmail,
  }) async {
    final clientRequestId = const Uuid().v4();

    try {
      final user = _auth?.currentUser;
      final userId = user?.uid ?? 'guest_user';
      final paymentId = const Uuid().v4();
      final orderRefId = id ?? 'order_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      final paymentData = <String, dynamic>{
        'id': paymentId,
        'user_id': userId,
        'user_email': userEmail ?? user?.email ?? '',
        'amount': amountInPaise ?? 0,
        'currency': currency ?? 'INR',
        'order_id': orderRefId,
        'client_request_id': clientRequestId,
        'razorpay_order_id': orderRefId,
        'items': items ?? [],
        'status': 'created',
        'created_at': now,
        'updated_at': now,
      };

      final firestoreInstance = _firestore;
      if (firestoreInstance != null) {
        await firestoreInstance
            .collection('payments')
            .doc(paymentId)
            .set(paymentData);

        FirebaseMessaging.instance.subscribeToTopic(orderRefId);
      }

      return {'status': 200, 'payment': paymentData};
    } catch (e, stackTrace) {
      log('[PaymentServices] Error creating payment order: $e $stackTrace');
      throw Exception('[PaymentServices] Error creating payment order: $e');
    }
  }

  Future<PaymentModel?> getPaymentStatus(String paymentId) async {
    try {
      final firestoreInstance = _firestore;
      if (firestoreInstance == null) return null;

      final doc = await firestoreInstance
          .collection('payments')
          .doc(paymentId)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Payment not found: $paymentId');
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      if (!data.containsKey('id') || data['id'] == null) {
        data['id'] = doc.id;
      }

      return PaymentModel.fromJson(data);
    } catch (e, stackTrace) {
      log('Error get payment status: $e $stackTrace');
      throw Exception('Error get payment status: $e $stackTrace');
    }
  }

  Future<Map<String, dynamic>?> getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final firestoreInstance = _firestore;
      final user = _auth?.currentUser;
      if (firestoreInstance == null || user == null) {
        return {'success': true, 'payments': []};
      }

      final snapshot = await firestoreInstance
          .collection('payments')
          .where('user_id', isEqualTo: user.uid)
          .get();

      final allData = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || data['id'] == null) {
          data['id'] = doc.id;
        }
        return data;
      }).toList();

      // Sort by created_at descending
      allData.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['created_at']?.toString() ?? '') ??
            DateTime(2000);
        final bDate =
            DateTime.tryParse(b['created_at']?.toString() ?? '') ??
            DateTime(2000);
        return bDate.compareTo(aDate);
      });

      // Pagination
      final from = (page - 1) * limit;
      if (from >= allData.length) {
        return {'success': true, 'payments': []};
      }
      final to = (from + limit > allData.length)
          ? allData.length
          : from + limit;

      return {'success': true, 'payments': allData.sublist(from, to)};
    } catch (e, stackTrace) {
      log('Error get payment history: $e $stackTrace');
      throw Exception('Error get payment history: $e $stackTrace');
    }
  }

  /// Fetches confirmed orders for the logged-in user from Firestore 'orders' collection
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final firestoreInstance = _firestore;
      final user = _auth?.currentUser;
      if (firestoreInstance == null || user == null) {
        return [];
      }

      final snapshot = await firestoreInstance
          .collection('orders')
          .where('user_id', isEqualTo: user.uid)
          .get();

      final orders = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || data['id'] == null) {
          data['id'] = doc.id;
        }
        return OrderModel.fromJson(data);
      }).toList();

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e, stackTrace) {
      log('Error getting user orders: $e $stackTrace');
      return [];
    }
  }
}
