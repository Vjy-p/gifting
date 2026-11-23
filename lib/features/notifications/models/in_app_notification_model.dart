import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InAppNotificationModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final String status;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const InAppNotificationModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  factory InAppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return InAppNotificationModel(
      id: doc.id,
      orderId: map['order_id']?.toString() ?? '',
      orderNumber: map['order_number']?.toString() ?? '',
      status: map['status']?.toString() ?? 'placed',
      title: map['title']?.toString() ?? 'Order Update',
      body: map['body']?.toString() ?? '',
      isRead: map['read'] == true,
      createdAt: _parseDate(map['created_at']),
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
    );
  }

  factory InAppNotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return InAppNotificationModel(
      id: id ?? map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: map['order_id']?.toString() ?? '',
      orderNumber: map['order_number']?.toString() ?? '',
      status: map['status']?.toString() ?? 'placed',
      title: map['title']?.toString() ?? 'Order Update',
      body: map['body']?.toString() ?? '',
      isRead: map['read'] == true,
      createdAt: _parseDate(map['created_at']),
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'status': status,
      'title': title,
      'body': body,
      'read': isRead,
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }

  InAppNotificationModel copyWith({
    String? id,
    String? orderId,
    String? orderNumber,
    String? status,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return InAppNotificationModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Visual icon corresponding to order state
  IconData get iconData {
    switch (status.toLowerCase()) {
      case 'placed':
      case 'confirmed':
      case 'paid':
        return Icons.shopping_bag_outlined;
      case 'packed':
        return Icons.inventory_2_outlined;
      case 'picked':
      case 'dispatched':
        return Icons.local_shipping_outlined;
      case 'out_for_delivery':
      case 'out delivery':
        return Icons.delivery_dining_outlined;
      case 'delivered':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  /// Color accent for the status pill
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'placed':
      case 'confirmed':
      case 'paid':
        return const Color(0xFF2563EB); // Royal Blue
      case 'packed':
        return const Color(0xFFD97706); // Amber
      case 'picked':
      case 'dispatched':
        return const Color(0xFF7C3AED); // Violet
      case 'out_for_delivery':
      case 'out delivery':
        return const Color(0xFFEA580C); // Warm Orange
      case 'delivered':
        return const Color(0xFF059669); // Emerald Green
      default:
        return const Color(0xFF13543E);
    }
  }

  /// Human-friendly status badge text
  String get formattedStatus {
    switch (status.toLowerCase()) {
      case 'placed':
      case 'confirmed':
      case 'paid':
        return 'Order Placed';
      case 'packed':
        return 'Packed';
      case 'picked':
      case 'dispatched':
        return 'Picked Up';
      case 'out_for_delivery':
      case 'out delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Relative human-readable timestamp (e.g., 'Just now', '12m ago')
  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
