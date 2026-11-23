import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/constants/constants.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/features/payment/models/payment_result.dart';
import 'package:gifting/features/payment/services/payment_services.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:hive/hive.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class IRazorpayPaymentService {
  Future<void> initialize();
  void dispose();
  Future<PaymentResult> openCheckout({
    required List<ProductModel> cart,
    required String customerEmail,
    String? customerContact,
  });
}

class RazorpayPaymentService implements IRazorpayPaymentService {
  Razorpay? _razorpay;
  Completer<PaymentResult>? _pendingCompleter;
  bool _initialized = false;
  String? _currentDbPaymentId;
  String? _currentOrderId;

  PaymentServices paymentServices = PaymentServices();

  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb || Get.testMode) {
      return;
    }
    try {
      _razorpay = Razorpay();
      _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      _initialized = true;
      log('[Razorpay] Initialized successfully');
    } catch (e) {
      log('[Razorpay] Initialization error: $e');
    }
  }

  Future<void> _clearActiveSession() async {
    try {
      if (Hive.isBoxOpen(HiveService.settingsBoxName)) {
        await HiveService.settingsBox.delete('active_payment_session');
      }
    } catch (e) {
      log('[Razorpay] Error clearing active session: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log(
      '[Razorpay] Payment Success: paymentId=${response.paymentId}, orderId=${response.orderId}',
    );

    await _clearActiveSession();

    if (_currentDbPaymentId != null) {
      try {
        final data = await paymentServices.verifyPayment(
          currentDbPaymentId: _currentDbPaymentId!,
          orderId: response.orderId ?? _currentOrderId ?? '',
          paymentId: response.paymentId ?? '',
          signature: response.signature ?? '',
        );

        if (data is Map && data['error'] != null) {
          log('[Razorpay] Verification rejected: ${data['error']}');
          if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
            _pendingCompleter!.complete(
              PaymentResult.failure(
                errorMessage: 'Payment verification failed: ${data['error']}',
                errorReason: 'verification_failed',
              ),
            );
            return;
          }
        }
        log('[Razorpay] Payment verified successfully in Firebase: $data');
      } catch (e) {
        log('[Razorpay] Error calling verifyPayment: $e');
      }
    }

    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(
        PaymentResult.success(
          paymentId: response.paymentId ?? '',
          orderId: response.orderId ?? _currentOrderId,
          signature: response.signature,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    log(
      '[Razorpay] Payment Error: code=${response.code}, message=${response.message}',
    );

    await _clearActiveSession();

    final isCancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    String reason = 'gateway_error';
    String userMessage = response.message ?? 'Payment failed';

    if (response.code == Razorpay.NETWORK_ERROR) {
      reason = 'network_error';
      userMessage = 'Network connection was lost during payment. If any amount was debited from your account, it will be automatically refunded by your bank within 3–5 working days.';
    } else if (response.code == Razorpay.TLS_ERROR) {
      reason = 'tls_error';
      userMessage = 'Secure connection to bank servers failed. Please check your internet connection and try again.';
    } else if (response.code == Razorpay.INVALID_OPTIONS) {
      reason = 'invalid_options';
      userMessage =
          'Invalid Razorpay configuration or key. Check your Razorpay Key ID.';
    } else if (isCancelled) {
      reason = 'user_cancelled';
      userMessage = 'Payment was cancelled by the user.';
    } else {
      final msgLower = (response.message ?? '').toLowerCase();
      if (msgLower.contains('bank') ||
          msgLower.contains('timeout') ||
          msgLower.contains('unavailable') ||
          msgLower.contains('declined') ||
          msgLower.contains('server')) {
        reason = 'bank_server_down';
        userMessage = 'Bank servers are temporarily unavailable or timed out. If money was debited, your bank will refund it within 24–48 hours.';
      }
    }

    // Update Firestore 'payments' document with failure status and error details
    if (_currentDbPaymentId != null) {
      try {
        await paymentServices.recordPaymentFailure(
          currentDbPaymentId: _currentDbPaymentId!,
          errorCode: response.code.toString(),
          errorDescription: userMessage,
          errorReason: reason,
          isCancelled: isCancelled,
        );
      } catch (e) {
        log('[Razorpay] Error recording payment failure in Firebase: $e');
      }
    }

    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      if (isCancelled) {
        _pendingCompleter!.complete(
          PaymentResult.cancelled(message: userMessage),
        );
      } else {
        _pendingCompleter!.complete(
          PaymentResult.failure(
            errorMessage: userMessage,
            errorCode: response.code,
            errorReason: reason,
          ),
        );
      }
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    log('[Razorpay] External Wallet Selected: ${response.walletName}');
    await _clearActiveSession();

    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(
        PaymentResult.success(
          paymentId: 'wallet_${response.walletName ?? "external"}',
          orderId: _currentOrderId,
        ),
      );
    }
  }

  @override
  Future<PaymentResult> openCheckout({
    required List<ProductModel> cart,
    required String customerEmail,
    String? customerContact,
  }) async {
    if (Get.testMode) {
      return PaymentResult.success(
        paymentId: 'pay_test_${const Uuid().v4()}',
        orderId: 'order_test_${const Uuid().v4()}',
      );
    }

    if (kIsWeb) {
      return PaymentResult.failure(
        errorMessage:
            'Razorpay checkout is currently supported on mobile platforms.',
        errorReason: 'unsupported_platform',
      );
    }

    if (!_initialized) {
      await initialize();
    }

    // Cancel any previous pending checkout attempt
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(
        PaymentResult.cancelled(message: 'Superseded by new payment request'),
      );
    }

    _pendingCompleter = Completer<PaymentResult>();
    _currentDbPaymentId = null;
    _currentOrderId = null;

    final clientRequestId = const Uuid().v4();

    int totalRupees = 0;
    for (final ProductModel p in cart) {
      final qty = p.quantity > 0 ? p.quantity : 1;
      totalRupees += p.price * qty;
    }
    final int amountInPaise = totalRupees * 100;

    if (amountInPaise < 100) {
      return PaymentResult.failure(
        errorMessage: 'Minimum order amount must be at least ₹1.00',
        errorReason: 'amount_too_low',
      );
    }

    // Create payment order record in Firebase
    try {
      final orderRefId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      final data = await paymentServices.getOrderID(
        id: orderRefId,
        amountInPaise: amountInPaise,
        currency: 'INR',
        userEmail: customerEmail,
        items: cart
            .map(
              (p) => {
                'id': p.id,
                'name': p.name,
                'quantity': p.quantity > 0 ? p.quantity : 1,
                'min_price': p.price,
                'customisations': p.selectedCustomisations,
              },
            )
            .toList(),
      );

      if (data != null && data['payment'] != null) {
        final paymentData = data['payment'] as Map;
        _currentDbPaymentId = paymentData['id']?.toString();
        _currentOrderId = paymentData['order_id']?.toString();
      }
    } catch (e) {
      log(
        '[Razorpay] Firebase create payment order error: $e. Proceeding with standard checkout.',
      );
    }

    // Save active in-flight session to Hive for reconciliation if app is killed/backgrounded
    try {
      if (Hive.isBoxOpen(HiveService.settingsBoxName)) {
        await HiveService.settingsBox.put('active_payment_session', {
          'db_payment_id': _currentDbPaymentId,
          'order_id': _currentOrderId,
          'amount_in_paise': amountInPaise,
          'customer_email': customerEmail,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      log('[Razorpay] Could not save active_payment_session: $e');
    }

    // Check if using placeholder key
    final isPlaceholderKey =
        Constants.razorpayKey.isEmpty ||
        Constants.razorpayKey == 'rzp_test_placeholder' ||
        Constants.razorpayKey.contains('placeholder');

    if (isPlaceholderKey && Get.context != null) {
      log(
        '[Razorpay] Placeholder key detected ($Constants.razorpayKey). Prompting test mode simulation.',
      );

      final shouldSimulate = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.developer_mode, color: Colors.orange),
              SizedBox(width: 8),
              Text('Razorpay Test Mode', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Razorpay Key is currently set to placeholder (rzp_test_placeholder).\n\n'
                'Real Razorpay SDK requires an active Key ID from the Razorpay Dashboard (starts with rzp_test_).',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Would you like to simulate a successful payment to test Firebase order creation and cart clearing?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Get.back(result: true),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Simulate Success'),
            ),
          ],
        ),
      );

      if (shouldSimulate == true) {
        await _clearActiveSession();
        final mockPaymentId =
            'pay_sim_${DateTime.now().millisecondsSinceEpoch}';
        final mockOrderId =
            _currentOrderId ?? 'order_${DateTime.now().millisecondsSinceEpoch}';

        if (_currentDbPaymentId != null) {
          try {
            await paymentServices.verifyPayment(
              currentDbPaymentId: _currentDbPaymentId!,
              orderId: mockOrderId,
              paymentId: mockPaymentId,
              signature: 'simulated_test_signature',
            );
          } catch (e) {
            log('[Razorpay] Verification error in simulation: $e');
          }
        }

        return PaymentResult.success(
          paymentId: mockPaymentId,
          orderId: mockOrderId,
          signature: 'simulated_test_signature',
        );
      } else {
        await _clearActiveSession();
        if (_currentDbPaymentId != null) {
          try {
            await paymentServices.recordPaymentFailure(
              currentDbPaymentId: _currentDbPaymentId!,
              errorCode: 'CANCELLED_BY_USER',
              errorDescription:
                  'Payment cancelled: Razorpay key not configured.',
              isCancelled: true,
            );
          } catch (e) {
            log('[Razorpay] Error recording cancellation in Firebase: $e');
          }
        }
        return PaymentResult.cancelled(
          message:
              'Payment cancelled: Please configure an active Razorpay Key.',
        );
      }
    }

    final sanitizedNotes = <String, String>{
      'client_request_id': clientRequestId,
    };
    if (_currentDbPaymentId != null && _currentDbPaymentId!.isNotEmpty) {
      sanitizedNotes['db_payment_id'] = _currentDbPaymentId!;
    }

    final sanitizedPrefill = <String, String>{};
    if (customerEmail.isNotEmpty && customerEmail.contains('@')) {
      sanitizedPrefill['email'] = customerEmail;
    }
    if (customerContact != null && customerContact.isNotEmpty) {
      sanitizedPrefill['contact'] = customerContact;
    }

    final options = <String, dynamic>{
      'key': Constants.razorpayKey,
      'amount': amountInPaise,
      'name': 'Tribe Green Store',
      'description': 'Order for ${cart.length} item(s)',
      'currency': 'INR',
      'timeout': 180,
      if (sanitizedPrefill.isNotEmpty) 'prefill': sanitizedPrefill,
      if (sanitizedNotes.isNotEmpty) 'notes': sanitizedNotes,
      'theme': {'color': '#245C45'},
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      log('[Razorpay] Open checkout exception: $e');
      await _clearActiveSession();
      if (_currentDbPaymentId != null) {
        try {
          await paymentServices.recordPaymentFailure(
            currentDbPaymentId: _currentDbPaymentId!,
            errorCode: 'OPEN_CHECKOUT_EXCEPTION',
            errorDescription: e.toString(),
            isCancelled: false,
          );
        } catch (err) {
          log('[Razorpay] Error recording open exception in Firebase: $err');
        }
      }
      if (!_pendingCompleter!.isCompleted) {
        _pendingCompleter!.complete(
          PaymentResult.failure(
            errorMessage: e.toString(),
            errorReason: 'exception',
          ),
        );
      }
    }

    return _pendingCompleter!.future;
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _initialized = false;
  }
}
