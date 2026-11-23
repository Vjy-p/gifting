import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';
import 'package:gifting/features/cart/services/local_cart_services.dart';
import 'package:gifting/features/order/models/order_model.dart';
import 'package:gifting/features/payment/controllers/payment_controller.dart';
import 'package:gifting/features/payment/models/payment_history_model.dart';
import 'package:gifting/features/payment/models/payment_result.dart';
import 'package:gifting/features/payment/models/payment_status.dart';
import 'package:gifting/features/payment/services/payment_services.dart';
import 'package:gifting/features/payment/services/razorpay_payment_service.dart';
import 'package:gifting/features/products/models/product_model.dart';

class MockLocalCartServices implements LocalCartServices {
  final List<ProductModel> _storage = [];

  @override
  Future<void> saveProduct(ProductModel product) async {
    final idx = _storage.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _storage[idx] = product;
    } else {
      _storage.add(product);
    }
  }

  @override
  List<ProductModel> getCart() => List<ProductModel>.from(_storage);

  @override
  Future<void> deleteProduct(String id) async {
    _storage.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> clearCart() async {
    _storage.clear();
  }
}

class MockRazorpayPaymentService implements IRazorpayPaymentService {
  bool shouldSucceed = true;

  @override
  Future<void> initialize() async {}

  @override
  void dispose() {}

  @override
  Future<PaymentResult> openCheckout({
    required List<ProductModel> cart,
    required String customerEmail,
    String? customerContact,
  }) async {
    if (shouldSucceed) {
      return PaymentResult.success(
        paymentId: 'pay_test_123',
        orderId: 'order_test_456',
        signature: 'sig_test_789',
      );
    } else {
      return PaymentResult.failure(
        errorMessage: 'Payment gateway rejected',
        errorCode: 400,
      );
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  group('Cart to Payment Flow Tests', () {
    test(
      'CartController adds products and calculates total with quantity',
      () async {
        final mockCartService = MockLocalCartServices();
        final cartController = CartController(localServices: mockCartService);

        final product1 = ProductModel(
          id: 'p1',
          name: 'Corporate Mug',
          category: 'Drinkware',
          price: 325,
          description: 'Ceramic coffee mug',
          quantity: 2,
        );

        final product2 = ProductModel(
          id: 'p2',
          name: 'Denim Jacket',
          category: 'Apparel',
          price: 1750,
          description: 'Denim jacket',
          quantity: 1,
        );

        cartController.updateCart(product: product1);
        expect(cartController.cart.length, 1);
        expect(cartController.total.value, 500); // 250 * 2

        cartController.updateCart(product: product2);
        expect(cartController.cart.length, 2);
        expect(cartController.total.value, 2000); // 500 + 1500

        // Update quantity
        product1.quantity = 4;
        cartController.updateCart(product: product1);
        expect(cartController.total.value, 2500); // 250*4 + 1500

        // Remove product
        cartController.removeProductCart(product: product2);
        expect(cartController.cart.length, 1);
        expect(cartController.total.value, 1000); // 250 * 4

        // Clear cart
        await cartController.clearCartData();
        expect(cartController.cart.isEmpty, true);
        expect(cartController.total.value, 0);
      },
    );

    test(
      'PaymentController handles empty cart and successful order flow',
      () async {
        final mockRazorpay = MockRazorpayPaymentService();
        final paymentController = PaymentController(
          paymentService: mockRazorpay,
        );

        // 1. Attempt checkout with empty cart
        final emptyResult = await paymentController.createOrder(cart: []);
        expect(emptyResult.status, PaymentStatus.failed);
        expect(emptyResult.errorMessage, 'Cart is empty.');

        // 2. Checkout with valid cart
        final product = ProductModel(
          id: 'p_test',
          name: 'Test Product',
          category: 'Test',
          price: 400,
          description: 'Desc',
          quantity: 2,
        );

        final successResult = await paymentController.createOrder(
          cart: [product],
        );
        expect(successResult.isSuccess, true);
        expect(successResult.paymentId, 'pay_test_123');
        expect(paymentController.status.value, PaymentStatus.captured);
      },
    );

    test('PaymentHistoryModel parses json safely', () {
      final json = {
        'id': 'pay_doc_1',
        'amount': 50000,
        'currency': 'INR',
        'status': 'captured',
        'razorpay_payment_id': 'pay_12345',
        'razorpay_order_id': 'order_12345',
        'created_at': '2026-11-18T12:00:00Z',
        'updated_at': '2026-11-18T12:05:00Z',
      };

      final model = PaymentHistoryModel.fromJson(json);
      expect(model.id, 'pay_doc_1');
      expect(model.amount, 50000);
      expect(model.amountInRupees, 500.0);
      expect(model.currency, 'INR');
      expect(model.isSuccessful, true);
      expect(model.razorpayPaymentId, 'pay_12345');
    });

    test('OrderModel parses json and calculates item totals correctly', () {
      final json = {
        'id': 'ord_123',
        'order_number': 'ORD-123',
        'user_id': 'user_456',
        'user_email': 'test@example.com',
        'total_amount': 1500.0,
        'currency': 'INR',
        'payment_id': 'pay_789',
        'payment_status': 'paid',
        'order_status': 'confirmed',
        'items': [
          {
            'id': 'p1',
            'name': 'Corporate Mug',
            'quantity': 3,
            'min_price': 500,
            'customisations': ['Logo printing'],
          },
        ],
        'created_at': '2026-11-18T12:00:00Z',
        'paid_at': '2026-11-18T12:05:00Z',
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, 'ord_123');
      expect(order.orderNumber, 'ORD-123');
      expect(order.totalAmount, 1500.0);
      expect(order.paymentStatus, 'paid');
      expect(order.orderStatus, 'confirmed');
      expect(order.items.length, 1);
      expect(order.items.first.itemTotal, 1500);
      expect(order.items.first.name, 'Corporate Mug');
    });

    test(
      'PaymentServices.recordPaymentFailure builds valid failure payload',
      () async {
        final paymentServices = PaymentServices();
        final result = await paymentServices.recordPaymentFailure(
          currentDbPaymentId: 'test_db_pay_1',
          errorCode: '1',
          errorDescription: 'Invalid Razorpay configuration or key.',
          isCancelled: false,
        );

        expect(result['success'], true);
        expect(result['payment']['status'], 'failed');
        expect(result['payment']['error_code'], '1');
        expect(
          result['payment']['error_description'],
          'Invalid Razorpay configuration or key.',
        );
        expect(result['payment']['failed_at'], isNotNull);
      },
    );

    test(
      'PaymentServices.recordPaymentFailure marks cancelled status',
      () async {
        final paymentServices = PaymentServices();
        final result = await paymentServices.recordPaymentFailure(
          currentDbPaymentId: 'test_db_pay_2',
          errorCode: '2',
          errorDescription: 'Payment cancelled by user',
          isCancelled: true,
        );

        expect(result['success'], true);
        expect(result['payment']['status'], 'cancelled');
        expect(result['payment']['error_code'], '2');
      },
    );

    test('PaymentResult identifies network errors and bank downtime', () {
      final networkResult = PaymentResult.failure(
        errorMessage: 'Network connection was lost during payment.',
        errorCode: 0,
        errorReason: 'network_error',
      );
      expect(networkResult.isNetworkError, true);
      expect(networkResult.isBankDowntime, false);

      final bankResult = PaymentResult.failure(
        errorMessage: 'Bank server is temporarily unavailable or timed out.',
        errorCode: 504,
        errorReason: 'bank_server_down',
      );
      expect(bankResult.isBankDowntime, true);
      expect(bankResult.isNetworkError, false);
    });
  });
}
