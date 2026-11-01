import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/services/common_services.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/catalogue/controllers/catalogue_controller.dart';
import 'package:gifting/features/enquiries/models/enquiry_model.dart';
import 'package:gifting/features/enquiries/services/enquiry_services.dart';
import 'package:gifting/features/enquiries/services/local_services.dart';
import 'package:intl/intl.dart';

import '../../products/models/product_model.dart';

class EnquiryController extends GetxController {
  EnquiryController({
    ProductModel? initialProduct,
    int? initialQuantity,
    List<String>? initialCustomisations,
  }) {
    if (initialProduct != null) selectedProducts.add(initialProduct);
    if (initialQuantity != null) {
      quantityController.text = initialQuantity.toString();
    }
    if (initialCustomisations != null) {
      customisations.assignAll(initialCustomisations);
    }
  }

  final EnquiryServices enquiryServices = EnquiryServices();
  final localEnquiryServices = LocalEnquiryServices();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final nameFocus = FocusNode();
  final companyController = TextEditingController();
  final companyFocus = FocusNode();
  final phoneController = TextEditingController();
  final phoneFocus = FocusNode();
  final emailController = TextEditingController();
  final emailFocus = FocusNode();
  final quantityController = TextEditingController();
  final quantityFocus = FocusNode();
  final messageController = TextEditingController();
  final messageFocus = FocusNode();
  final deliveryDateController = TextEditingController();
  final deliveryDateFocus = FocusNode();

  final selectedProducts = <ProductModel>[].obs;
  final customisations = <String>[].obs;

  final selectedOccasion = RxnString();
  final selectedBudget = RxnString();
  final deliveryDate = Rxn<DateTime>();

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

  @override
  void onClose() {
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    quantityController.dispose();
    messageController.dispose();
    nameFocus.dispose();
    companyFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    quantityFocus.dispose();
    messageFocus.dispose();
    deliveryDateController.dispose();
    deliveryDateFocus.dispose();
    super.onClose();
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

  void fieldFocusChange({
    required FocusNode currentFocus,
    FocusNode? nextFocus,
  }) {
    currentFocus.unfocus();
    if (nextFocus != null) {
      nextFocus.requestFocus();
    }
  }

  void toggleCustomisation(String option, bool selected) {
    if (selected) {
      if (!customisations.contains(option)) {
        customisations.add(option);
      }
    } else {
      customisations.remove(option);
    }
  }

  void addQuantity(String value) {
    quantityController.text = value;
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

  Future<void> pickDeliveryDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = deliveryDate.value ?? now.add(const Duration(days: 14));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      deliveryDate.value = picked;
      deliveryDateController.text = DateFormat('dd MMM yyyy').format(picked);
      deliveryDate.refresh();
      log('picked delivery date ${deliveryDate.value}');
    }
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
              subtitle: Text(product.priceRange),
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

  Future<void> submitForm() async {
    if (isSubmitting.value) return;

    if (!(formKey.currentState?.validate() ?? false)) return;

    if (selectedProducts.isEmpty) {
      customToast(
        title: 'Missing information',
        text: 'Please select atleast one product.',
      );
      return;
    } else if (selectedOccasion.value == null) {
      customToast(
        title: 'Missing information',
        text: 'Please select occasion.',
      );
      return;
    } else if (selectedBudget.value == null) {
      customToast(title: 'Missing information', text: 'Please select budget.');
      return;
    } else if (deliveryDate.value == null) {
      customToast(
        title: 'Missing information',
        text: 'Please select delivery date.',
      );
      return;
    }

    final quantity = int.tryParse(quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      customToast(
        title: 'Invalid quantity',
        text: 'Enter a valid number of units.',
      );
      return;
    }

    EnquiryModel enquiry = EnquiryModel(
      name: nameController.text.trim(),
      company: companyController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      occasion: selectedOccasion.value!,
      quantity: quantity,
      budget: selectedBudget.value!,
      deliveryDate: deliveryDate.value!,
      products: selectedProducts.toList(),
      customisations: customisations.toList(),
      message: messageController.text.trim(),
      source: GetPlatform.isWeb
          ? 'website'
          : GetPlatform.isIOS
          ? 'ios'
          : GetPlatform.isAndroid
          ? 'android'
          : 'none',
    );

    try {
      isSubmitting.value = true;

      final reference = await enquiryServices.submit(enquiry);
      enquiry = enquiry.copyWith(referenceCode: reference);

      // Get.offNamed(
      //   AppRoutes.thankYou,
      //   arguments: {'reference': reference, 'products': enquiry.products},
      // );

      openThankyouAlertBox(enquiry: enquiry, referenceCode: reference);
      await localEnquiryServices.saveEnquiry(enquiry);
      loadEnquiries();
    } catch (error) {
      log('Error submit form $error');
      customToast(
        title: 'Submission failed',
        text: 'Your enquiry could not be saved. Please try again.',
      );
    } finally {
      isSubmitting.value = false;
    }
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

  Future<dynamic> openThankyouAlertBox({
    required EnquiryModel enquiry,
    String? referenceCode,
  }) {
    return Get.dialog(
      barrierDismissible: false,
      barrierColor: AppColors.sage.withValues(alpha: 0.4),
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   height: 88,
                //   width: 88,
                //   decoration: const BoxDecoration(
                //     color: AppColors.sage,
                //     shape: BoxShape.circle,
                //   ),
                //   child: const Icon(
                //     Icons.check_circle_outline,
                //     size: 52,
                //     color: AppColors.primary,
                //   ),
                // ),
                Card(
                  color: AppColors.sage,
                  clipBehavior: Clip.antiAlias,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(16),
                    child: Image.asset(
                      'assets/gif/success.gif',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Thank you!',
                  style: TextStyle(fontSize: 34, letterSpacing: 0.25),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your enquiry has been submitted successfully. '
                  'Our team will contact you within 24 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enquiry reference',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        referenceCode ?? enquiry.referenceCode ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Selected products',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...enquiry.products.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(product.name)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      CommonServices().openWhatsApp(
                        referenceCode:
                            referenceCode ?? enquiry.referenceCode ?? '',
                        products: enquiry.products,
                        qunatity: enquiry.quantity.toString(),
                      );
                    },
                    child: const Text('Connect on Whatsapp'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
