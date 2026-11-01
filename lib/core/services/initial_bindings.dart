import 'package:get/get.dart';
import 'package:gifting/features/catalogue/controllers/catalogue_controller.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogueController>(() => CatalogueController());
    Get.lazyPut<EnquiryController>(() => EnquiryController());
  }
}
