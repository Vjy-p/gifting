import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/catalogue/controllers/catalogue_controller.dart';
import 'package:gifting/features/enquiries/models/enquiry_model.dart';
import 'package:gifting/features/enquiries/services/enquiry_services.dart';
import 'package:gifting/features/enquiries/services/local_services.dart';

import '../../products/models/product_model.dart';

class EnquiryController extends GetxController {
  final EnquiryServices enquiryServices = EnquiryServices();
  final localEnquiryServices = LocalEnquiryServices();

  final selectedProducts = <ProductModel>[].obs;
  final customisations = <String>[].obs;

  final selectedOccasion = RxnString();
  final selectedBudget = RxnString();

  final isSubmitting = false.obs;

  List<EnquiryModel> enquiries = <EnquiryModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool error = false.obs;

  final occasions = const [
    'Employee Onboarding',
    'Corporate Diwali Gifting',
    'New Year Gifts',
    'Client and Vendor Gifting',
    'Events and Trade Shows',
    'Employee Recognition',
  ];

  final budgetBands = const [
    'Under ₹500',
    '₹500–₹1,500',
    '₹1,500–₹3,000',
    'Above ₹3,000',
  ];

  final customisationOptions = const [
    'Logo printing',
    'Laser engraving',
    'Name personalisation',
  ];

  @override
  void onInit() {
    loadEnquiries();
    super.onInit();
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w.!#$%&’*+/=?^_`{|}~-]+@[\w-]+(?:\.[\w-]+)+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Enter a valid 10-digit Indian mobile number';
    }

    return null;
  }

  String? validateQuantity(String? value) {
    final quantity = int.tryParse(value ?? '');

    if (quantity == null || quantity <= 0) {
      return 'Enter a quantity greater than zero';
    }

    return null;
  }

  void setOccasion(String? value) {
    selectedOccasion.value = value;
  }

  void setBudget(String? value) {
    selectedBudget.value = value;
  }

  void toggleCustomisation(String option) {
    if (customisations.contains(option)) {
      customisations.remove(option);
    } else {
      customisations.add(option);
    }
  }

  void addCustomisation(List<String> value) {
    for (String v in value) {
      if (customisationOptions.contains(v)) {
        if (!customisations.contains(v)) {
          customisations.add(v);
        } else {
          customisations.remove(v);
        }
      }
    }
  }

  void addProduct(ProductModel product) {
    if (!selectedProducts.any((e) => e.id == product.id)) {
      selectedProducts.add(product);
    }
  }

  void removeProduct(ProductModel product) {
    selectedProducts.removeWhere((item) => item.id == product.id);
  }

  Future<void> addProducts() async {
    if (!Get.isRegistered<CatalogueController>()) {
      Get.put(CatalogueController());
    }

    final catalogue = Get.find<CatalogueController>();

    if (catalogue.products.isEmpty && !catalogue.isLoading.value) {
      await catalogue.loadProducts();
    }

    if (catalogue.products.isEmpty) {
      customToast(
        title: 'Products unavailable',
        text: 'Unable to load products. Please try again.',
      );
      return;
    }

    final selectedIds = selectedProducts.map((p) => p.id).toSet();

    final availableProducts = catalogue.products
        .where((product) => !selectedIds.contains(product.id))
        .toList();

    if (availableProducts.isEmpty) {
      customToast(
        title: 'All products selected',
        text: 'There are no additional products to add.',
      );
      return;
    }

    final chosen = await Get.dialog<ProductModel>(
      SimpleDialog(
        constraints: const BoxConstraints(maxWidth: 900),
        title: const Text('Add a product'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: availableProducts.map((product) {
          return SimpleDialogOption(
            onPressed: () => Get.back(result: product),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.comfortable,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(16),
              ),
              minLeadingWidth: 40,
              leading: SizedBox(
                height: 60,
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(8),
                  child: CachedNetworkImage(
                    height: 60,
                    width: 60,
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.gif_box, size: 40),
                  ),
                ),
              ),
              title: Text(product.name),
              subtitle: Text(product.price.toString()),
              contentPadding: EdgeInsets.zero,
            ),
          );
        }).toList(),
      ),
    );

    if (chosen != null &&
        !selectedProducts.any((product) => product.id == chosen.id)) {
      selectedProducts.add(chosen);
    }
  }

  void removeSelectedProduct(ProductModel product) {
    selectedProducts.removeWhere((item) => item.id == product.id);
  }

  Future<EnquiryModel?> submitForm({
    required String name,
    required String company,
    required String number,
    required email,
    required DateTime date,
    required String quantity,
    required String? message,
  }) async {
    if (isSubmitting.value) return null;

    if (selectedProducts.isEmpty) {
      customToast(
        title: 'Missing information',
        text: 'Please select atleast one product.',
      );
      return null;
    } else if (selectedOccasion.value == null) {
      customToast(
        title: 'Missing information',
        text: 'Please select occasion.',
      );
      return null;
    } else if (selectedBudget.value == null) {
      customToast(title: 'Missing information', text: 'Please select budget.');
      return null;
    }

    final quantity0 = int.tryParse(quantity.trim());

    if (quantity0 == null || quantity0 <= 0) {
      customToast(
        title: 'Invalid quantity',
        text: 'Enter a valid number of units.',
      );
      return null;
    }

    EnquiryModel enquiry = EnquiryModel(
      name: name.trim(),
      company: company.trim(),
      phone: number.trim(),
      email: email.trim(),
      occasion: selectedOccasion.value!,
      quantity: quantity0,
      budget: selectedBudget.value!,
      deliveryDate: date,
      products: selectedProducts.toList(),
      customisations: customisations.toList(),
      message: message?.trim() ?? '',
      source: GetPlatform.isWeb
          ? 'website'
          : GetPlatform.isIOS
          ? 'ios'
          : GetPlatform.isAndroid
          ? 'android'
          : 'none',
    );
    log('new enquiry ${enquiry.toJson()}');

    try {
      isSubmitting.value = true;

      // Check if any product in selectedProducts has already been enquiried
      EnquiryModel? existingMatch;
      for (final p in selectedProducts) {
        final match = localEnquiryServices.findEnquiryByProduct(p);
        if (match != null) {
          existingMatch = match;
          break;
        }
      }

      if (existingMatch != null) {
        // Product is already enquiried -> Update the existing enquiry
        final updatedEnquiry = existingMatch.copyWith(
          name: name.trim(),
          company: company.trim(),
          phone: number.trim(),
          email: email.trim(),
          occasion: selectedOccasion.value!,
          quantity: quantity0,
          budget: selectedBudget.value!,
          deliveryDate: date,
          products: selectedProducts.toList(),
          customisations: customisations.toList(),
          message: message?.trim() ?? existingMatch.message,
        );

        // Update in backend Firestore
        await enquiryServices.update(updatedEnquiry);
        // Update in local Hive
        await localEnquiryServices.saveEnquiry(updatedEnquiry);
        enquiry = updatedEnquiry;
        log('Updated existing enquiry: ${existingMatch.referenceCode}');
      } else {
        // Only new products -> Submit new enquiry
        final reference = await enquiryServices.submit(enquiry);
        enquiry = enquiry.copyWith(referenceCode: reference);
        await localEnquiryServices.saveEnquiry(enquiry);
        log('Created new enquiry: $reference');
      }

      clearData();
      loadEnquiries();
      return enquiry;
    } catch (error) {
      log('Error submit form $error');
      customToast(
        title: 'Submission failed',
        text: 'Your enquiry could not be saved. Please try again.',
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearData() {
    selectedProducts.clear();
    selectedBudget.value = null;
    selectedOccasion.value = null;
    customisations.clear();
  }

  Future<void> loadEnquiries() async {
    try {
      isLoading.value = true;
      error.value = false;

      enquiries = localEnquiryServices.getAllEnquiries();

      isLoading.value = false;
      error.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = true;
      log('Erro load enquiries $e');
    } finally {
      isLoading.value = false;
    }
  }
}
