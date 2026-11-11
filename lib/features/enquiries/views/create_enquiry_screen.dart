import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/services/common_services.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';
import 'package:gifting/core/widgets/custom_text_field.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/authentication/models/user_model.dart';
import 'package:gifting/features/authentication/services/local_auth_services.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';
import 'package:gifting/features/enquiries/models/enquiry_model.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:intl/intl.dart';

class CreateEnquiryScreen extends StatefulWidget {
  const CreateEnquiryScreen({super.key});

  @override
  State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {
  final controller = Get.find<EnquiryController>();

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

  final occasionFocus = FocusNode();
  final budgetFocus = FocusNode();

  DateTime? deliveryDate;
  UserModel? user = LocalAuthServices.getUserDetails();

  @override
  void initState() {
    super.initState();
    initialise();
  }

  void initialise() {
    final args = Get.arguments;
    log('args $args');
    if (args?['product'] != null) {
      controller.addProduct(
        ProductModel.fromJson(jsonDecode(args?['product'])),
      );
    }

    if (args?['customisations'] != null) {
      controller.addCustomisation(args?['customisations'] ?? []);
    }

    if (args?['quantity'] != null) {
      quantityController.text = args?['quantity']?.toString() ?? '';
    }
    if (user != null) {
      nameController.text = user?.name ?? '';
      emailController.text = user?.email ?? '';
      phoneController.text = user?.mobile ?? '';
      companyController.text = user?.company ?? '';
    }
  }

  @override
  void dispose() {
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
    if (mounted) controller.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;
    log('width ${MediaQuery.of(context).size.width} ');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Quote'),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Form(
            key: formKey,
            child: Row(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (!isMobile) productsWidget(isMobile),
                // VerticalDivider(),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile) productsWidget(isMobile),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 8),
                        child: Text(
                          'Tell us about your gifting needs',
                          style: isMobile
                              ? Theme.of(context).textTheme.headlineSmall
                              : Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        'Share your requirements and our team can prepare '
                        'a suitable corporate gifting proposal.',
                        style: isMobile
                            ? Theme.of(context).textTheme.bodySmall
                            : Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                      _sectionTitle('Your details'),
                      _responsiveFields(context, [
                        CustomTextField(
                          label: 'Full name',
                          icon: const Icon(Icons.person),
                          controller: nameController,
                          currentFocus: nameFocus,
                          nextFocus: companyFocus,
                        ),
                        CustomTextField(
                          label: 'Company name',
                          icon: const Icon(Icons.factory),
                          controller: companyController,
                          currentFocus: companyFocus,
                          nextFocus: phoneFocus,
                        ),
                        CustomTextField(
                          label: 'Phone number',
                          icon: const Icon(Icons.call),
                          controller: phoneController,
                          currentFocus: phoneFocus,
                          nextFocus: emailFocus,
                          isMobileNumber: true,
                        ),
                        CustomTextField(
                          label: 'Email',
                          icon: const Icon(Icons.email),
                          controller: emailController,
                          currentFocus: emailFocus,
                          nextFocus: quantityFocus,
                          isEmail: true,
                        ),
                      ]),
                      const SizedBox(height: 28),
                      _sectionTitle('Order requirements'),
                      _responsiveFields(context, [
                        CustomTextField(
                          label: 'Number of units',
                          icon: const Icon(Icons.calculate),
                          controller: quantityController,
                          currentFocus: quantityFocus,
                          nextFocus: occasionFocus,
                          isNumber: true,
                        ),
                        Obx(
                          () => CustomDropDownField(
                            label: 'Occasion *',
                            icon: const Icon(Icons.festival),
                            initialValue: controller.selectedOccasion.value,
                            items: controller.occasions,
                            currentFocus: occasionFocus,
                            nextFocus: budgetFocus,
                            onSaved: (value) {
                              controller.setOccasion(value?.toString());
                            },
                          ),
                        ),
                        Obx(
                          () => CustomDropDownField(
                            label: 'Budget per unit *',
                            icon: const Icon(Icons.monetization_on),
                            initialValue: controller.selectedBudget.value,
                            items: controller.budgetBands,
                            currentFocus: budgetFocus,
                            nextFocus: deliveryDateFocus,
                            onSaved: (value) {
                              controller.setBudget(value.toString());
                            },
                          ),
                        ),
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery date',
                              style: TextStyle(
                                fontSize: 15,
                                // color: textColor ?? CustomColors.textColor,
                              ),
                            ),
                            TextFormField(
                              // initialValue: deliveryDate.value != null
                              //     ? DateFormat('dd MMM yyyy')
                              //           .format(deliveryDate.value!)
                              //     : 'Choose delivery date',
                              controller: deliveryDateController,
                              focusNode: deliveryDateFocus,
                              readOnly: true,

                              decoration: const InputDecoration(
                                isDense: true,
                                hint: Text('Choose delivery date'),
                                prefixIcon: Icon(Icons.calendar_month),
                              ),

                              onTap: () async {
                                DateTime? resp = await pickDeliveryDate(
                                  context,
                                );
                                if (resp != null) {
                                  deliveryDateController.text = DateFormat(
                                    'dd MMM yyyy',
                                  ).format(resp);
                                  setState(() {});
                                }
                                if (context.mounted) {
                                  fieldFocusChange(
                                    context: context,
                                    currentFocus: deliveryDateFocus,
                                    nextFocus: messageFocus,
                                  );
                                }
                              },
                              onTapOutside: (event) {
                                fieldFocusChange(
                                  context: context,
                                  currentFocus: deliveryDateFocus,
                                  nextFocus: messageFocus,
                                );
                              },
                              onChanged: (value) {
                                // pickDeliveryDate(context);
                              },
                              validator: (value) => value == null
                                  ? 'Select a delivery date'
                                  : null,
                            ),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 28),
                      _sectionTitle('Customisation'),
                      Obx(
                        () => Column(
                          children: controller.customisationOptions.map((
                            option,
                          ) {
                            return CheckboxListTile(
                              value: controller.customisations.contains(option),
                              visualDensity: VisualDensity.comfortable,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              title: Text(option),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primary,
                              onChanged: (selected) {
                                controller.toggleCustomisation(option);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Additional message (optional)',
                        controller: messageController,
                        // icon: const Icon(Icons.message),
                        maxLines: 4,
                        currentFocus: messageFocus,
                        validate: false,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your information will be used to handle your gifting enquiry.',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => Align(
                          alignment: AlignmentGeometry.center,
                          child: ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : () async {
                                    if (formKey.currentState?.validate() ==
                                            true &&
                                        deliveryDate != null) {
                                      EnquiryModel? enquiry = await controller
                                          .submitForm(
                                            name: nameController.text,
                                            company: companyController.text,
                                            number: phoneController.text,
                                            email: emailController.text,
                                            date: deliveryDate!,
                                            quantity: quantityController.text,
                                            message: messageController.text,
                                          );
                                      if (enquiry != null) {
                                        openThankyouAlertBox(enquiry: enquiry);
                                      }
                                    } else {
                                      if (deliveryDate == null) {
                                        customToast(
                                          title: 'Missing information',
                                          text: 'Please select delivery date.',
                                        );
                                      }
                                    }
                                  },
                            child: controller.isSubmitting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Submit Enquiry'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget productsWidget(bool isMobile) {
    return isMobile
        ? Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Selected Products',
                      style: TextStyle(fontSize: 16, letterSpacing: 0.15),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.addProducts,
                    icon: const Icon(Icons.add),
                    label: const Text('Add product'),
                  ),
                ],
              ),
              Obx(() {
                if (controller.selectedProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products selected yet.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return SizedBox(
                  height: 220,
                  child: ListView.separated(
                    itemCount: controller.selectedProducts.length,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 20),
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      final product = controller.selectedProducts[index];
                      return AspectRatio(
                        aspectRatio: 0.7,
                        child: Card(
                          child: Stack(
                            children: [
                              Column(
                                spacing: 10,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: product.imageUrl ?? '',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.card_giftcard_outlined,
                                                  size: 42,
                                                  color: AppColors.primary,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  onPressed: () {
                                    controller.removeSelectedProduct(product);
                                  },
                                  icon: const Icon(Icons.remove_circle),
                                  tooltip: 'Remove',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                  ),
                );
              }),
            ],
          )
        : Expanded(
            flex: 2,
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Selected Products',
                        style: TextStyle(fontSize: 16, letterSpacing: 0.15),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.addProducts,
                      icon: const Icon(Icons.add),
                      label: const Text('Add product'),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.selectedProducts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Center(child: Text('No products selected yet.')),
                    );
                  }
                  return Wrap(
                    children: List.generate(
                      controller.selectedProducts.length,
                      (i) {
                        final product = controller.selectedProducts[i];
                        return Card(
                          child: Stack(
                            children: [
                              Column(
                                spacing: 10,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 160,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: product.imageUrl ?? '',
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) {
                                            return Center(
                                              child: Icon(
                                                Icons.card_giftcard_outlined,
                                                size: 42,
                                                color: AppColors.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 160,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  onPressed: () {
                                    controller.removeSelectedProduct(product);
                                  },
                                  icon: const Icon(Icons.remove_circle),
                                  tooltip: 'Remove',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.darkGreen,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _responsiveFields(BuildContext context, List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600 ? 1 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          crossAxisSpacing: 16,
          mainAxisSpacing: 2,
          // childAspectRatio: 1.2,
          mainAxisExtent: 106,
          children: fields,
        );
      },
    );
  }

  Future<DateTime?> pickDeliveryDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = deliveryDate ?? now.add(const Duration(days: 14));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      deliveryDate = picked;
      log('picked delivery date $deliveryDate');
      return picked;
    } else {
      return null;
    }
  }

  Future<dynamic> openThankyouAlertBox({
    required EnquiryModel enquiry,
    String? referenceCode,
  }) {
    return Get.dialog(
      barrierDismissible: false,
      // barrierColor: AppColors.sage.withValues(alpha: 0.4),
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                Text(
                  'Thank you!',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your enquiry has been submitted successfully. '
                  'Our team will contact you within 24 hours.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        referenceCode ?? enquiry.referenceCode ?? '',
                        // style: TextStyle(
                        //   fontWeight: FontWeight.w700,
                        //   color: AppColors.darkGreen,
                        //   fontSize: 18,
                        // ),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Selected products',
                        style: Theme.of(context).textTheme.bodySmall,
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                      ),
                                ),
                              ),
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
