import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/features/products/models/product_model.dart';

class LocalCartServices {
  Future<void> saveProduct(ProductModel product) async {
    final reference = product.id;

    await HiveService.cartBox.put(reference, product);
  }

  List<ProductModel> getCart() {
    final cart = HiveService.cartBox.values.toList();
    // cart.sort((a, b) {
    //   return (b.createdAt ?? DateTime(2000)).compareTo(
    //     a.createdAt ?? DateTime(2000),
    //   );
    // });

    return cart;
  }

  Future<void> deleteProduct(String id) async {
    await HiveService.cartBox.delete(id);
  }

  Future<void> clearCart() async {
    await HiveService.cartBox.clear();
  }
}
