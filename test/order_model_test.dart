import 'package:flutter_test/flutter_test.dart';
import 'package:gifting/features/order/models/order_model.dart';

void main() {
  group('OrderStatus Enum Tests', () {
    test('OrderStatus values and labels match specifications', () {
      expect(OrderStatus.newOrder.value, 'New');
      expect(OrderStatus.processing.value, 'Processing');
      expect(OrderStatus.outForDelivery.value, 'Out For Delivery');
      expect(OrderStatus.delivered.value, 'Delivered');
      expect(OrderStatus.cancelled.value, 'Cancelled');

      expect(OrderStatus.stringValues, [
        'New',
        'Processing',
        'Out For Delivery',
        'Delivered',
        'Cancelled',
      ]);

      expect(OrderStatus.allFilters, [
        'All',
        'New',
        'Processing',
        'Out For Delivery',
        'Delivered',
        'Cancelled',
      ]);
    });

    test(
      'OrderStatus.fromString parses various cases and aliases correctly',
      () {
        expect(OrderStatus.fromString('New'), OrderStatus.newOrder);
        expect(OrderStatus.fromString('Processing'), OrderStatus.processing);
        expect(OrderStatus.fromString('processing'), OrderStatus.processing);
        expect(
          OrderStatus.fromString('Out For Delivery'),
          OrderStatus.outForDelivery,
        );
        expect(
          OrderStatus.fromString('out_for_delivery'),
          OrderStatus.outForDelivery,
        );
        expect(OrderStatus.fromString('Delivered'), OrderStatus.delivered);
        expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
        expect(OrderStatus.fromString('Cancelled'), OrderStatus.cancelled);
        expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
        expect(OrderStatus.fromString(null), OrderStatus.newOrder);
        expect(OrderStatus.fromString(''), OrderStatus.newOrder);
      },
    );

    test('Step indices and cancellation properties', () {
      expect(OrderStatus.newOrder.stepIndex, 0);
      expect(OrderStatus.processing.stepIndex, 1);
      expect(OrderStatus.outForDelivery.stepIndex, 2);
      expect(OrderStatus.delivered.stepIndex, 3);
      expect(OrderStatus.cancelled.stepIndex, -1);

      expect(OrderStatus.newOrder.canCancel, true);
      expect(OrderStatus.processing.canCancel, false);
      expect(OrderStatus.outForDelivery.canCancel, false);
      expect(OrderStatus.delivered.canCancel, false);
      expect(OrderStatus.cancelled.canCancel, false);

      expect(OrderStatus.newOrder.isActive, true);
      expect(OrderStatus.processing.isActive, true);
      expect(OrderStatus.outForDelivery.isActive, true);
      expect(OrderStatus.delivered.isActive, false);
      expect(OrderStatus.cancelled.isActive, false);
    });
  });

  group('OrderModel Serialization Tests', () {
    test('Parses user sample Firestore order document seamlessly', () {
      final sampleJson = <String, dynamic>{
        'item_count': 1,
        'user_email': 'tester@gmail.com',
        'order_number': 'order_1795072322976',
        'payment_status': 'paid',
        'created_at': '2026-11-19T12:42:02.977741',
        'paid_at': '2026-11-19T12:43:49.264685',
        'order_status': 'confirmed',
        'updated_at': '2026-11-19T12:44:55.981000',
        'user_id': '95eDZNE509Rimjj7lYZlDRHtFxv1',
        'total_amount': 20250.0,
        'payment_id': 'pay_U1wnOcMrm9wfrt',
        'amount_in_paise': 2025000,
        'fcm_token': 'epaB7J0YSQaShKeMAFFti6:APA91bFBwUnDr-mBOfHE_qIe2KtEip3tvZIQoJvPYo2k1EUM0fPPTd1Z2qOyk9zw_Vuhf58qhPx5TBeCuKlY1DDg8ODfF4hbIsPopw4fcTJGG-SUA7hCpPw',
        'currency': 'INR',
        'id': 'order_1795072322976',
        'payment_db_id': '98ad187f-15ee-4b6b-b0a5-8403db658645',
        'items': [
          {
            'quantity': 45,
            'min_price': 450,
            'name': 'Stainless Steel Travel Mug',
            'id': 'b4dc524e-b20a-4f1a-bde2-3fba45949e72',
            'customisations': ['Logo printing'],
          },
        ],
        'order_id': 'order_1795072322976',
        'status': 'Processing',
        'payment_signature': '',
      };

      final order = OrderModel.fromJson(sampleJson);

      expect(order.id, 'order_1795072322976');
      expect(order.orderNumber, 'order_1795072322976');
      expect(order.userId, '95eDZNE509Rimjj7lYZlDRHtFxv1');
      expect(order.userEmail, 'tester@gmail.com');
      expect(order.status, OrderStatus.processing);
      expect(order.formattedStatus, 'Processing');
      expect(order.stepIndex, 1);
      expect(order.isActive, true);
      expect(order.isCancelled, false);
      expect(order.canCancel, false);
      expect(order.totalAmount, 20250.0);
      expect(order.amountInPaise, 2025000);
      expect(order.itemCount, 1);
      expect(order.paymentId, 'pay_U1wnOcMrm9wfrt');
      expect(order.paymentDbId, '98ad187f-15ee-4b6b-b0a5-8403db658645');
      expect(order.paymentStatus, 'paid');
      expect(order.currency, 'INR');

      // Items assertions
      expect(order.items.length, 1);
      final item = order.items.first;
      expect(item.id, 'b4dc524e-b20a-4f1a-bde2-3fba45949e72');
      expect(item.name, 'Stainless Steel Travel Mug');
      expect(item.quantity, 45);
      expect(item.minPrice, 450);
      expect(item.itemTotal, 20250);
      expect(item.customisations, ['Logo printing']);

      // Serialization round-trip
      final jsonOut = order.toJson();
      expect(jsonOut['status'], 'Processing');
      expect(jsonOut['total_amount'], 20250.0);
      expect(jsonOut['amount_in_paise'], 2025000);
      expect(jsonOut['payment_id'], 'pay_U1wnOcMrm9wfrt');
    });
  });
}
