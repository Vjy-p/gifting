import 'dart:developer';

import 'package:get/get.dart';
import 'package:gifting/features/cart/services/local_cart_services.dart';

import '../../products/models/product_model.dart';

class CartController extends GetxController {
  CartController({LocalCartServices? localServices})
    : _cartServices = localServices ?? LocalCartServices();
  final LocalCartServices _cartServices;

  final RxBool isLoading = false.obs;
  final RxBool error = false.obs;

  final RxList<ProductModel> cart = <ProductModel>[].obs;
  final RxInt total = 0.obs;

  @override
  void onInit() {
    loadCart();
    super.onInit();
  }

  void _recalculateTotal() {
    int value = 0;
    for (final ProductModel p in cart) {
      final qty = p.quantity > 0 ? p.quantity : 1;
      value += p.price * qty;
    }
    total.value = value;
  }

  void updateCart({required ProductModel product}) {
    final int index = cart.indexWhere((e) => e.id == product.id);

    if (product.quantity <= 0) {
      removeProductCart(product: product);
      return;
    }

    if (index == -1) {
      cart.add(product);
    } else {
      cart[index] = product;
    }

    _cartServices.saveProduct(product);
    _recalculateTotal();
  }

  void removeProductCart({required ProductModel product, int? quantity}) {
    cart.removeWhere((e) => e.id == product.id);
    _cartServices.deleteProduct(product.id);
    _recalculateTotal();
  }

  Future<void> clearData() async {
    try {
      await _cartServices.clearCart();
    } catch (e, stackTrace) {
      log('Error clear cart $e -- $stackTrace');
    }
  }

  Future<void> clearCartData() async {
    await clearData();
    cart.clear();
    total.value = 0;
  }

  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      error.value = false;

      cart.value = _cartServices.getCart();
      _recalculateTotal();

      isLoading.value = false;
      error.value = false;
    } catch (e, stackTrace) {
      isLoading.value = false;
      error.value = true;
      log('Error load cart $e -- $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }
}
