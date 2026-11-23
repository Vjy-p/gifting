import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';

class CartBellButton extends StatelessWidget {
  final Color? color;
  final double iconSize;

  const CartBellButton({super.key, this.color, this.iconSize = 22});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return Obx(() {
      final count = cartController.cart.length;
      return Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: IconButton(
          tooltip: 'Cart',
          iconSize: 20,
          padding: EdgeInsets.zero,
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Get.toNamed(AppRoutes.cart),
        ),
      );
    });
  }
}
