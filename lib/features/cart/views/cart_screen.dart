import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';
import 'package:gifting/features/cart/views/cart_tile.dart';
import 'package:gifting/features/payment/controllers/payment_controller.dart';
import 'package:gifting/features/payment/models/payment_result.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    final paymentController = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());

    return PopScope(
      canPop: !paymentController.isProcessing.value,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && paymentController.isProcessing.value) {
          final shouldLeave = await _showExitWarningDialog(context);
          if (shouldLeave == true && context.mounted) {
            paymentController.isProcessing.value = false;
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
          actions: [
            Obx(() {
              if (cartController.cart.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () {
                  _showClearCartDialog(context, cartController);
                },
                icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                label: const Text('Clear'),
              );
            }),
            const SizedBox(width: 8),
          ],
        ),
        body: Obx(() {
          if (cartController.cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.secondaryText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Cart is Empty',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore gifts and merchandise in our catalogue and add them to your cart.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.catalogue);
                      },
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Explore Catalogue'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: cartController.cart.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              return CartTile(product: cartController.cart[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        }),
        bottomNavigationBar: Obx(() {
          if (cartController.cart.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total (${cartController.cart.length} ${cartController.cart.length == 1 ? 'item' : 'items'})',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${cartController.total.value}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      final isProcessing = paymentController.isProcessing.value;
                      return SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  final result = await paymentController
                                      .createOrder(cart: cartController.cart);
                                  if (result.isSuccess) {
                                    await cartController.clearCartData();
                                    if (context.mounted) {
                                      _showSuccessDialog(context, result);
                                    }
                                  } else if (!result.isCancelled) {
                                    if (context.mounted) {
                                      _showFailureDialog(context, result);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isProcessing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Proceed to Payment',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<bool?> _showExitWarningDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Payment in Progress'),
          ],
        ),
        content: const Text(
          'Your payment is currently being processed.\n\n'
          'Leaving this screen or closing the app now may interrupt the payment or cause delayed confirmation.\n\n'
          'Are you sure you want to leave?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay on Screen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Leave Anyway',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(BuildContext context, PaymentResult result) {
    IconData icon = Icons.error_outline_rounded;
    Color iconColor = Colors.redAccent;
    String title = 'Payment Failed';
    String message = result.errorMessage ?? 'Payment could not be completed.';

    if (result.isNetworkError) {
      icon = Icons.wifi_off_rounded;
      iconColor = Colors.orange;
      title = 'Network Connection Lost';
      message =
          'Your connection was lost during checkout.\n\n'
          'If money was debited from your bank account, it will be automatically refunded by your bank within 3–5 working days.';
    } else if (result.isBankDowntime) {
      icon = Icons.account_balance_outlined;
      iconColor = Colors.deepOrange;
      title = 'Bank Server Unavailable';
      message =
          'The bank server timed out or is temporarily down.\n\n'
          'Your funds are safe. If debited, your bank will refund the amount within 24–48 hours.\n\n'
          'You may retry with another payment method (e.g. UPI, Netbanking, or another card).';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 50),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Get.toNamed(AppRoutes.support);
                },
                child: const Text('Contact Support'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    CartController cartController,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartController.clearCartData();
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, PaymentResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 54,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your payment has been verified and your order is confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
            if (result.orderId != null && result.orderId!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Order: ${result.orderId}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
            if (result.paymentId != null && result.paymentId!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Payment ID: ${result.paymentId}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Get.toNamed(AppRoutes.order);
                },
                child: const Text('View Orders'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Get.offAllNamed(AppRoutes.catalogue);
                },
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
