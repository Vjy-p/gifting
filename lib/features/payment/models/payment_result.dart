import 'package:gifting/features/payment/models/payment_status.dart';

/// Encapsulates the outcome of a Razorpay payment attempt
class PaymentResult {
  final PaymentStatus status;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
  final int? errorCode;
  final String? errorReason;
  final bool isCancelled;

  const PaymentResult({
    required this.status,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
    this.errorCode,
    this.errorReason,
    this.isCancelled = false,
  });

  /// Compatibility getter for legacy callers
  String? get paymentIntentId => paymentId;

  bool get isSuccess => status == PaymentStatus.captured;
  bool get isFailure => status == PaymentStatus.failed;

  bool get isNetworkError =>
      errorReason == 'network_error' ||
      errorCode == 0 ||
      (errorMessage?.toLowerCase().contains('network') ?? false);

  bool get isBankDowntime =>
      errorReason == 'bank_server_down' ||
      (errorMessage?.toLowerCase().contains('bank') ?? false) ||
      (errorMessage?.toLowerCase().contains('timeout') ?? false) ||
      (errorMessage?.toLowerCase().contains('unavailable') ?? false);

  factory PaymentResult.success({
    String? paymentId,
    String? paymentIntentId,
    String? orderId,
    String? signature,
  }) {
    return PaymentResult(
      status: PaymentStatus.captured,
      paymentId: paymentId ?? paymentIntentId ?? '',
      orderId: orderId,
      signature: signature,
    );
  }

  factory PaymentResult.cancelled({String? message}) {
    return PaymentResult(
      status: PaymentStatus.cancelled,
      isCancelled: true,
      errorReason: 'user_cancelled',
      errorMessage: message ?? 'Payment was cancelled by the user.',
    );
  }

  factory PaymentResult.failure({
    String? errorMessage,
    int? errorCode,
    String? errorReason,
  }) {
    return PaymentResult(
      status: PaymentStatus.failed,
      errorMessage: errorMessage ?? 'Payment processing failed.',
      errorCode: errorCode,
      errorReason: errorReason,
    );
  }

  @override
  String toString() {
    return 'PaymentResult(status: $status, paymentId: $paymentId, errorCode: $errorCode, reason: $errorReason, message: $errorMessage)';
  }
}
