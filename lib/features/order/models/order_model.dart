import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gifting/features/order/models/order_status.dart';

export 'package:gifting/features/order/models/order_status.dart';

class OrderItemModel {
  final String id;
  final String name;
  final int quantity;
  final int minPrice;
  final List<String> customisations;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.minPrice,
    this.customisations = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      minPrice: (json['min_price'] as num?)?.toInt() ??
          (json['price'] as num?)?.toInt() ??
          0,
      customisations: List<String>.from(
        json['customisations'] ?? json['customizations'] ?? const [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'min_price': minPrice,
      'customisations': customisations,
    };
  }

  int get itemTotal => minPrice * quantity;
  List<String> get customizations => customisations;
}

class OrderModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final String userId;
  final String userEmail;
  final int itemCount;
  final double totalAmount;
  final int amountInPaise;
  final String currency;
  final String? paymentId;
  final String? paymentDbId;
  final String paymentStatus;
  final String? paymentSignature;
  final String? fcmToken;
  final OrderStatus status;
  final String orderStatus;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? updatedAt;
  final String? trackingId;
  final String? deliveryPartner;
  final String? deliveryAddress;
  final String? notes;
  final String? statusNote;

  const OrderModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.userId,
    required this.userEmail,
    required this.itemCount,
    required this.totalAmount,
    required this.amountInPaise,
    required this.currency,
    this.paymentId,
    this.paymentDbId,
    required this.paymentStatus,
    this.paymentSignature,
    this.fcmToken,
    required this.status,
    required this.orderStatus,
    required this.items,
    required this.createdAt,
    this.paidAt,
    this.updatedAt,
    this.trackingId,
    this.deliveryPartner,
    this.deliveryAddress,
    this.notes,
    this.statusNote,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final rawItems = json['items'] as List? ?? [];
    final id = docId ??
        json['id']?.toString() ??
        json['order_id']?.toString() ??
        json['order_number']?.toString() ??
        '';

    final orderNum = json['order_number']?.toString() ??
        json['order_id']?.toString() ??
        (id.isNotEmpty ? id : 'ORD-${DateTime.now().millisecondsSinceEpoch}');

    final parsedItems = rawItems
        .map((item) =>
            OrderItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    // Order status parsing with OrderStatus enum as authority
    final statusRaw = json['status']?.toString();
    final orderStatusRaw = json['order_status']?.toString();
    final status = OrderStatus.fromString(statusRaw ?? orderStatusRaw);

    final total = (json['total_amount'] as num?)?.toDouble() ??
        ((json['amount_in_paise'] as num?) != null
            ? (json['amount_in_paise'] as num).toDouble() / 100.0
            : ((json['amount'] as num?) != null
                ? (json['amount'] as num).toDouble() / 100.0
                : 0.0));

    final paise = (json['amount_in_paise'] as num?)?.toInt() ??
        (total * 100).round();

    final count = (json['item_count'] as num?)?.toInt() ??
        (parsedItems.isNotEmpty ? parsedItems.length : 1);

    return OrderModel(
      id: id.isNotEmpty ? id : orderNum,
      orderId: json['order_id']?.toString() ?? (id.isNotEmpty ? id : orderNum),
      orderNumber: orderNum,
      userId: json['user_id']?.toString() ?? json['uid']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      itemCount: count,
      totalAmount: total,
      amountInPaise: paise,
      currency: json['currency']?.toString() ?? 'INR',
      paymentId: json['payment_id']?.toString() ?? json['paymentId']?.toString(),
      paymentDbId: json['payment_db_id']?.toString(),
      paymentStatus: json['payment_status']?.toString() ?? 'paid',
      paymentSignature: json['payment_signature']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      status: status,
      orderStatus: orderStatusRaw ?? status.value,
      items: parsedItems,
      createdAt: _parseDate(json['created_at']),
      paidAt: _parseNullableDate(json['paid_at']),
      updatedAt: _parseNullableDate(json['updated_at']),
      trackingId: json['tracking_id']?.toString(),
      deliveryPartner: json['delivery_partner']?.toString(),
      deliveryAddress: json['delivery_address']?.toString() ??
          json['shipping_address']?.toString(),
      notes: json['notes']?.toString(),
      statusNote: json['status_note']?.toString(),
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromJson(data, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_number': orderNumber,
      'user_id': userId,
      'user_email': userEmail,
      'item_count': itemCount,
      'total_amount': totalAmount,
      'amount_in_paise': amountInPaise,
      'currency': currency,
      'payment_id': paymentId,
      if (paymentDbId != null) 'payment_db_id': paymentDbId,
      'payment_status': paymentStatus,
      if (paymentSignature != null) 'payment_signature': paymentSignature,
      if (fcmToken != null) 'fcm_token': fcmToken,
      'status': status.value,
      'order_status': orderStatus,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (trackingId != null) 'tracking_id': trackingId,
      if (deliveryPartner != null) 'delivery_partner': deliveryPartner,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (notes != null) 'notes': notes,
      if (statusNote != null) 'status_note': statusNote,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// UI convenience getters delegating directly to OrderStatus
  String get formattedStatus => status.label;
  Color get statusColor => status.color;
  Color get statusBackgroundColor => status.backgroundColor;
  IconData get statusIcon => status.icon;
  int get stepIndex => status.stepIndex;
  bool get isCancelled => status.isCancelled;
  bool get isDelivered => status.isDelivered;
  bool get isActive => status.isActive;
  bool get canCancel => status.canCancel;

  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
