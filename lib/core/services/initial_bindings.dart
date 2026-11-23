import 'package:get/get.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';
import 'package:gifting/features/catalogue/controllers/catalogue_controller.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';
import 'package:gifting/features/notifications/controllers/notification_controller.dart';
import 'package:gifting/features/order/controllers/order_controller.dart';
import 'package:gifting/features/support/controller/support_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogueController>(() => CatalogueController());
    Get.lazyPut<EnquiryController>(() => EnquiryController());
    Get.lazyPut<SupportController>(() => SupportController());
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
  }
}
