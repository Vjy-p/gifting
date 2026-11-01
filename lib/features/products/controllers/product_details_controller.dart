import 'package:get/get.dart';

import '../models/product_model.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController({required this.product});

  final ProductModel product;

  final quantity = 100.obs;

  final customisations = <String>[].obs;

  final availableCustomisations = const [
    'Logo printing',
    'Laser engraving',
    'Name personalisation',
  ];

  final occasions = const [
    'Employee Onboarding',
    'Corporate Diwali Gifting',
    'New Year Gifts',
    'Client and Vendor Gifting',
    'Events and Trade Shows',
    'Employee Recognition',
  ];

  void increaseQuantity() {
    quantity.value++;
  }

  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void toggleCustomisation(String option) {
    if (customisations.contains(option)) {
      customisations.remove(option);
    } else {
      customisations.add(option);
    }
  }
}
