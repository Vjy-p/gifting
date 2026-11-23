import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gifting/features/authentication/services/local_auth_services.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';
import 'package:gifting/features/enquiries/models/enquiry_model.dart';
import 'package:gifting/features/enquiries/services/enquiry_services.dart';
import 'package:gifting/features/enquiries/services/local_services.dart';
import 'package:gifting/features/profile/controllers/profile_controller.dart';

import '../models/product_model.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController({required this.product});

  final ProductModel product;
  bool _enquiryRecorded = false;

  void increaseQuantity() {
    product.quantity++;
    update();
  }

  void decreaseQuantity() {
    if (product.quantity > 1) {
      product.quantity--;
      update();
    }
  }

  void toggleCustomisation(String option) {
    if (product.selectedCustomisations.contains(option)) {
      product.selectedCustomisations.remove(option);
    } else {
      product.selectedCustomisations.add(option);
    }
    update();
  }

  /// Automatically records an enquiry for this viewed product to both
  /// local Hive storage and the backend Firestore database when the user exits.
  Future<void> recordEnquiryOnExit() async {
    if (_enquiryRecorded) return;
    _enquiryRecorded = true;

    try {
      final user = LocalAuthServices.getUserDetails();
      final authUser = FirebaseAuth.instance.currentUser;

      final name = (user?.name.trim().isNotEmpty ?? false)
          ? user!.name.trim()
          : (authUser?.displayName?.trim().isNotEmpty ?? false)
          ? authUser!.displayName!.trim()
          : 'Customer';

      final email = (user?.email.trim().isNotEmpty ?? false)
          ? user!.email.trim()
          : (authUser?.email?.trim().isNotEmpty ?? false)
          ? authUser!.email!.trim()
          : 'customer@tribegreen.com';

      final phone = (user?.mobile.trim().isNotEmpty ?? false)
          ? user!.mobile.trim()
          : (authUser?.phoneNumber?.trim().isNotEmpty ?? false)
          ? authUser!.phoneNumber!.trim()
          : '9876543210';

      final company = (user?.company.trim().isNotEmpty ?? false)
          ? user!.company.trim()
          : 'Individual';

      final occasion = product.selectedOccasions.isNotEmpty
          ? product.selectedOccasions.first
          : product.occasions.isNotEmpty
          ? product.occasions.first
          : 'Corporate Gifting';

      final now = DateTime.now();
      final localService = LocalEnquiryServices();
      final enquiryService = EnquiryServices();

      // Check if this product is already enquiried (locally in Hive or in Firestore backend)
      EnquiryModel? existingEnquiry = localService.findEnquiryByProduct(
        product,
      );
      if (existingEnquiry == null && email.isNotEmpty) {
        existingEnquiry = await enquiryService.findEnquiryByProductInFirestore(
          product: product,
          userEmail: email,
        );
      }

      if (existingEnquiry != null) {
        // Product is ALREADY enquiried -> Update the existing enquiry
        final updatedProducts = existingEnquiry.products.map((p) {
          final matches =
              (product.id.isNotEmpty && p.id == product.id) ||
              (product.name.trim().isNotEmpty &&
                  p.name.trim().toLowerCase() ==
                      product.name.trim().toLowerCase());
          return matches ? product : p;
        }).toList();

        int totalQty = 0;
        int totalAmount = 0;
        for (final p in updatedProducts) {
          final q = p.quantity > 0 ? p.quantity : 20;
          totalQty += q;
          totalAmount += (p.price * q);
        }

        final updatedCustomisations = {
          ...existingEnquiry.customisations,
          ...product.selectedCustomisations,
        }.toList();

        final updatedEnquiry = existingEnquiry.copyWith(
          quantity: totalQty,
          budget: '₹$totalAmount',
          products: updatedProducts,
          customisations: updatedCustomisations,
          message:
              'Enquiry updated for product: ${product.name} (Qty: ${product.quantity > 0 ? product.quantity : 20})',
          createdAt: existingEnquiry.createdAt ?? now,
        );

        // 1. Update in local Hive storage
        await localService.saveEnquiry(updatedEnquiry);
        log(
          '[ProductDetails] Existing enquiry updated in local Hive: ${existingEnquiry.referenceCode}',
        );

        // 2. Update in backend Firestore database
        await enquiryService.update(updatedEnquiry);
        log(
          '[ProductDetails] Existing enquiry updated in Firestore backend: ${existingEnquiry.referenceCode}',
        );
      } else {
        // Product is NEW -> Add only new product as a new enquiry
        final reference =
            'TG-${now.microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';
        final qty = product.quantity > 0 ? product.quantity : 20;

        final newEnquiry = EnquiryModel(
          id: reference,
          referenceCode: reference,
          name: name,
          company: company,
          phone: phone,
          email: email,
          occasion: occasion,
          quantity: qty,
          budget: '₹${product.price * qty}',
          deliveryDate: now.add(const Duration(days: 7)),
          products: [product],
          customisations: product.selectedCustomisations.isNotEmpty
              ? product.selectedCustomisations
              : product.customisations,
          // message: 'Product viewed: ${product.name}',
          message: '',
          source: GetPlatform.isWeb
              ? 'website'
              : GetPlatform.isIOS
              ? 'ios'
              : 'android',
          status: 'New',
          createdAt: now,
        );

        // 1. Store to local Hive database
        await localService.saveEnquiry(newEnquiry);
        log('[ProductDetails] New enquiry saved to local Hive: $reference');

        // 2. Submit to backend Firestore database
        await enquiryService.submit(newEnquiry);
        log(
          '[ProductDetails] New enquiry submitted to backend Firestore: $reference',
        );
      }

      // 3. If EnquiryController is active, reload enquiries list
      if (Get.isRegistered<EnquiryController>()) {
        Get.find<EnquiryController>().loadEnquiries();
      }

      if (!Get.isRegistered<ProfileController>()) {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }

      Get.find<ProfileController>().refreshStats();
    } catch (e, stackTrace) {
      log('[ProductDetails] Error recording enquiry on exit: $e $stackTrace');
    }
  }

  @override
  void onClose() {
    recordEnquiryOnExit();
    super.onClose();
  }
}
