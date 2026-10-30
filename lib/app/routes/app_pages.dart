import 'package:get/get.dart';
import 'package:gifting/features/catalogue/views/catalogue_screen.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';
import 'package:gifting/features/enquiries/views/create_enquiry_screen.dart';
import 'package:gifting/features/enquiries/views/enquiry_screen.dart';
import 'package:gifting/features/home/views/home_screen.dart';
import 'package:gifting/features/product_details/controllers/product_details_controller.dart';
import 'package:gifting/features/product_details/views/product_details_screen.dart';

import '../../features/catalogue/controllers/catalogue_controller.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CatalogueController>(() => CatalogueController());
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
    GetPage(
      name: AppRoutes.enquiry,
      page: () => const EnquiryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CatalogueController>(() => CatalogueController());
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductDetailsController>(
          () => ProductDetailsController(product: Get.arguments),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createEnquiry,
      page: () => const CreateEnquiryScreen(),
      binding: BindingsBuilder(() {
        final args = Get.arguments == null
            ? null
            : Get.arguments as Map<String, dynamic>;

        Get.lazyPut<EnquiryController>(
          () => EnquiryController(
            initialProduct: args?['product'],
            initialQuantity: args?['quantity'],
            initialCustomisations: List<String>.from(
              args?['customisations'] ?? [],
            ),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.catalogue,
      page: () => const CatalogueScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CatalogueController>()) {
          Get.lazyPut<CatalogueController>(() => CatalogueController());
        }
      }),
    ),
  ];
}
