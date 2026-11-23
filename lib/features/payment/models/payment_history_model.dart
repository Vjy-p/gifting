class PaymentHistoryModel {
  final String id;
  final int amount;
  final String currency;
  final String status;

  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpayStatus;
  final String? paymentMethod;

  final String? errorCode;
  final String? errorDescription;
  final String? errorReason;

  final String? receipt;

  final Map<String, dynamic>? metadata;

  final String? fulfilmentStatus;

  final DateTime createdAt;
  final DateTime updatedAt;

  final DateTime? paidAt;
  final DateTime? failedAt;

  const PaymentHistoryModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpayStatus,
    this.paymentMethod,
    this.errorCode,
    this.errorDescription,
    this.errorReason,
    this.receipt,
    this.metadata,
    this.fulfilmentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.failedAt,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return PaymentHistoryModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      status: json['status']?.toString() ?? 'unknown',
      razorpayOrderId: json['razorpay_order_id']?.toString(),
      razorpayPaymentId: json['razorpay_payment_id']?.toString(),
      razorpayStatus: json['razorpay_status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      errorCode: json['error_code']?.toString(),
      errorDescription: json['error_description']?.toString(),
      errorReason: json['error_reason']?.toString(),
      receipt: json['receipt']?.toString(),
      metadata: json['metadata'] == null
          ? null
          : Map<String, dynamic>.from(json['metadata'] as Map),
      fulfilmentStatus: json['fulfilment_status']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      paidAt: parseNullableDate(json['paid_at']),
      failedAt: parseNullableDate(json['failed_at']),
    );
  }

  double get amountInRupees => amount / 100.0;

  bool get isSuccessful => status == 'captured';

  bool get isFailed => status == 'failed';
}
