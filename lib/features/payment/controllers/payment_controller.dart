import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/authentication/services/local_auth_services.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';
import 'package:gifting/features/payment/models/payment_history_model.dart';
import 'package:gifting/features/payment/models/payment_result.dart';
import 'package:gifting/features/payment/models/payment_state_machine.dart';
import 'package:gifting/features/payment/models/payment_status.dart';
import 'package:gifting/features/payment/services/payment_services.dart';
import 'package:gifting/features/payment/services/razorpay_payment_service.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:hive/hive.dart';

class PaymentController extends GetxController {
  PaymentController({
    IRazorpayPaymentService? paymentService,
    PaymentServices? paymentServices,
    FirebaseAuth? auth,
  }) : _razorPayPaymentService = paymentService ?? RazorpayPaymentService(),
       _customPaymentServices = paymentServices,
       _customAuth = auth;

  final IRazorpayPaymentService _razorPayPaymentService;
  final PaymentServices? _customPaymentServices;
  final FirebaseAuth? _customAuth;

  PaymentServices get paymentServices =>
      _customPaymentServices ?? PaymentServices();

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final PaymentStateMachine stateMachine = PaymentStateMachine();

  late final Rx<PaymentStatus> status = stateMachine.state.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;

  RxList<PaymentHistoryModel> paymentHistoryList = <PaymentHistoryModel>[].obs;
  RxBool isLastPaymentHistory = false.obs;
  final RxBool isHistoryLoading = false.obs;
  final RxBool isHistoryError = false.obs;

  String getEffectiveUserId() {
    return _auth?.currentUser?.uid ??
        LocalAuthServices.getUserDetails()?.id ??
        '';
  }

  String getEffectiveUserEmail() {
    return _auth?.currentUser?.email ??
        LocalAuthServices.getUserDetails()?.email ??
        'customer@gifting.com';
  }

  @override
  void onInit() {
    super.onInit();
    _razorPayPaymentService.initialize();
    reconcilePendingPayments();
  }

  @override
  void onClose() {
    _razorPayPaymentService.dispose();
    super.onClose();
  }

  /// Reconciles any in-flight payments if the app was killed, backgrounded, or lost network during checkout
  Future<void> reconcilePendingPayments() async {
    try {
      if (!Hive.isBoxOpen(HiveService.settingsBoxName)) return;

      final session = HiveService.settingsBox.get('active_payment_session');
      if (session == null || session is! Map) return;

      final sessionMap = Map<String, dynamic>.from(session);
      final dbPaymentId = sessionMap['db_payment_id']?.toString();
      final timestampStr = sessionMap['timestamp']?.toString();
      if (dbPaymentId == null || dbPaymentId.isEmpty) {
        await HiveService.settingsBox.delete('active_payment_session');
        return;
      }

      final sessionTime = DateTime.tryParse(timestampStr ?? '');
      if (sessionTime != null &&
          DateTime.now().difference(sessionTime).inMinutes > 60) {
        // Expired session (> 1 hour)
        await HiveService.settingsBox.delete('active_payment_session');
        return;
      }

      log('[PaymentController] Found active in-flight payment session: $dbPaymentId. Reconciling with Firestore...');
      final payment = await paymentServices.getPaymentStatus(dbPaymentId);

      if (payment != null) {
        if (payment.status == PaymentStatus.captured) {
          log('[PaymentController] In-flight payment was captured ($dbPaymentId). Clearing cart.');
          await HiveService.settingsBox.delete('active_payment_session');
          if (Get.isRegistered<CartController>()) {
            await Get.find<CartController>().clearCartData();
          }
          customToast(
            title: 'Order Confirmed',
            text:
                'Your previous payment of ₹${payment.amountInRupees.toStringAsFixed(2)} was confirmed!',
          );
        } else if (payment.status == PaymentStatus.failed ||
            payment.status == PaymentStatus.cancelled) {
          log('[PaymentController] In-flight payment failed/cancelled ($dbPaymentId). Clearing session.');
          await HiveService.settingsBox.delete('active_payment_session');
        } else if (payment.status == PaymentStatus.created) {
          // If session is older than 15 minutes and still in created state, mark it timed out
          if (sessionTime != null &&
              DateTime.now().difference(sessionTime).inMinutes >= 15) {
            await paymentServices.recordPaymentFailure(
              currentDbPaymentId: dbPaymentId,
              errorCode: 'APP_CLOSED_TIMEOUT',
              errorDescription:
                  'Transaction timed out after app was closed or backgrounded.',
              isCancelled: true,
            );
            await HiveService.settingsBox.delete('active_payment_session');
          }
        }
      }
    } catch (e, stackTrace) {
      log('[PaymentController] Error reconciling pending payment: $e $stackTrace');
    }
  }

  Future<PaymentResult> createOrder({required List<ProductModel> cart}) async {
    if (cart.isEmpty) {
      customToast(title: 'Cart', text: 'Your cart is empty.');
      return const PaymentResult(
        status: PaymentStatus.failed,
        errorMessage: 'Cart is empty.',
      );
    }

    if (isProcessing.value) {
      return const PaymentResult(
        status: PaymentStatus.failed,
        errorMessage: 'A purchase is already in progress.',
      );
    }

    isProcessing.value = true;
    errorMessage.value = '';

    stateMachine.transition(PaymentStatus.checkoutStarted);
    status.value = stateMachine.state;

    try {
      final userEmail = getEffectiveUserEmail();

      stateMachine.transition(PaymentStatus.pending);
      status.value = stateMachine.state;

      // Open Razorpay Checkout modal
      final result = await _razorPayPaymentService.openCheckout(
        customerEmail: userEmail,
        cart: cart,
      );

      if (result.isSuccess) {
        stateMachine.transition(PaymentStatus.captured);
        status.value = stateMachine.state;
        customToast(title: 'Success', text: 'Payment completed successfully!');
        return result;
      } else if (result.isCancelled) {
        stateMachine.transition(PaymentStatus.cancelled);
        status.value = stateMachine.state;
        customToast(title: 'Cancelled', text: 'Payment was cancelled.');
        return result;
      } else {
        stateMachine.transition(PaymentStatus.failed);
        status.value = stateMachine.state;
        errorMessage.value = result.errorMessage ?? 'Payment failed.';

        if (result.isNetworkError) {
          customToast(title: 'Network Issue', text: errorMessage.value);
        } else if (result.isBankDowntime) {
          customToast(title: 'Bank Server Downtime', text: errorMessage.value);
        } else {
          customToast(title: 'Payment Failed', text: errorMessage.value);
        }

        return result;
      }
    } catch (e, stackTrace) {
      log('[PaymentController] Error during purchase: $e $stackTrace');
      stateMachine.transition(PaymentStatus.failed);
      status.value = stateMachine.state;
      errorMessage.value = e.toString();
      customToast(title: 'Payment Error', text: 'Payment error occurred.');
      return PaymentResult.failure(errorMessage: e.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> getPaymentHistory() async {
    try {
      if (paymentHistoryList.isNotEmpty) {
        return;
      }
      isHistoryLoading.value = true;
      isHistoryError.value = false;

      final response = await paymentServices.getPaymentHistory();
      if (response != null && response['payments'] != null) {
        final List data = response['payments'] as List;

        final List<PaymentHistoryModel> tempList = data
            .map(
              (e) => PaymentHistoryModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

        paymentHistoryList.addAll(
          tempList.where((p) => !paymentHistoryList.any((e) => e.id == p.id)),
        );

        isHistoryLoading.value = false;
        isHistoryError.value = false;
      } else {
        isHistoryLoading.value = false;
        isHistoryError.value = true;
      }
    } catch (e, stackTrace) {
      isHistoryLoading.value = false;
      isHistoryError.value = true;
      log('Error loading history: $e $stackTrace');
    }
  }
}
