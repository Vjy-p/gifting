import 'package:flutter/material.dart';

enum OrderStatus {
  newOrder('New'),
  processing('Processing'),
  outForDelivery('Out For Delivery'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.value);

  /// String value stored in Firestore / database.
  final String value;

  /// User-facing display label.
  String get label => value;

  /// Safe parser from string (handles case-insensitivity, underscores, legacy/payment values)
  static OrderStatus fromString(String? val) {
    if (val == null || val.trim().isEmpty) return OrderStatus.newOrder;
    final lower = val.toLowerCase().trim();
    switch (lower) {
      case 'processing':
      case 'packed':
      case 'picked':
      case 'dispatched':
        return OrderStatus.processing;
      case 'out for delivery':
      case 'out_for_delivery':
      case 'outfordelivery':
      case 'out delivery':
      case 'out_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'new':
      case 'created':
      case 'placed':
      case 'confirmed':
      case 'paid':
      case 'pending':
      default:
        return OrderStatus.newOrder;
    }
  }

  /// List of all allowed status strings.
  static List<String> get stringValues =>
      OrderStatus.values.map((e) => e.value).toList();

  /// List of filter values including 'All'.
  static const List<String> allFilters = [
    'All',
    'New',
    'Processing',
    'Out For Delivery',
    'Delivered',
    'Cancelled',
  ];

  /// List of allowed status values.
  static const List<String> allowedStatuses = [
    'New',
    'Processing',
    'Out For Delivery',
    'Delivered',
    'Cancelled',
  ];

  /// Primary theme color for status badge / indicators.
  Color get color {
    switch (this) {
      case OrderStatus.newOrder:
        return const Color(0xFF2563EB); // Blue
      case OrderStatus.processing:
        return const Color(0xFFD97706); // Amber / Orange
      case OrderStatus.outForDelivery:
        return const Color(0xFF7C3AED); // Purple
      case OrderStatus.delivered:
        return const Color(0xFF16A34A); // Green
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626); // Red
    }
  }

  /// Soft background color for status pills / badges.
  Color get backgroundColor {
    switch (this) {
      case OrderStatus.newOrder:
        return const Color(0xFFEFF6FF);
      case OrderStatus.processing:
        return const Color(0xFFFFFBEB);
      case OrderStatus.outForDelivery:
        return const Color(0xFFF5F3FF);
      case OrderStatus.delivered:
        return const Color(0xFFF0FDF4);
      case OrderStatus.cancelled:
        return const Color(0xFFFEF2F2);
    }
  }

  /// Icon representing the status.
  IconData get icon {
    switch (this) {
      case OrderStatus.newOrder:
        return Icons.shopping_bag_outlined;
      case OrderStatus.processing:
        return Icons.inventory_2_outlined;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  /// Stepper index for tracking milestones (0 to 3, or -1 if cancelled)
  int get stepIndex {
    switch (this) {
      case OrderStatus.newOrder:
        return 0;
      case OrderStatus.processing:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isCancelled => this == OrderStatus.cancelled;
  bool get isDelivered => this == OrderStatus.delivered;
  bool get isActive => !isCancelled && !isDelivered;
  bool get canCancel => this == OrderStatus.newOrder;
}
