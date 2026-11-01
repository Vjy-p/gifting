import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';

import '../controllers/enquiry_controller.dart';

class CreateEnquiryScreen extends GetView<EnquiryController> {
  const CreateEnquiryScreen({super.key});

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
            key: controller.formKey,
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
                      Text(
                        'Tell us about your gifting needs',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share your requirements and our team can prepare '
                        'a suitable corporate gifting proposal.',
                      ),
                      const SizedBox(height: 28),
                      _sectionTitle('Your details'),
                      _responsiveFields(context, [
                        _textField(
                          controller.nameController,
                          'Full name',
                          validator: controller.validateRequired,
                          focusNode: controller.nameFocus,
                          nextNode: controller.companyFocus,
                        ),
                        _textField(
                          controller.companyController,
                          'Company name',
                          validator: controller.validateRequired,
                          focusNode: controller.companyFocus,
                          nextNode: controller.phoneFocus,
                        ),
                        _textField(
                          controller.phoneController,
                          'Phone number',
                          hint: '+91 9876543210',
                          keyboardType: TextInputType.phone,
                          validator: controller.validatePhone,
                          focusNode: controller.phoneFocus,
                          nextNode: controller.emailFocus,
                          isMobile: true,
                        ),
                        _textField(
                          controller.emailController,
                          'Email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                          focusNode: controller.emailFocus,
                          // nextNode: controller.companyFocus,
                        ),
                      ]),
                      const SizedBox(height: 28),
                      _sectionTitle('Order requirements'),
                      _responsiveFields(context, [
                        Obx(
                          () => DropdownButtonFormField<String>(
                            initialValue: controller.selectedOccasion.value,
                            decoration: const InputDecoration(
                              labelText: 'Occasion *',
                            ),
                            items: controller.occasions
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              controller.setOccasion(value);
                            },
                            validator: (value) =>
                                value == null ? 'Select an occasion' : null,
                          ),
                        ),
                        _textField(
                          controller.quantityController,
                          'Number of units',
                          keyboardType: TextInputType.number,
                          validator: controller.validateQuantity,
                          focusNode: controller.quantityFocus,
                        ),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            initialValue: controller.selectedBudget.value,
                            decoration: const InputDecoration(
                              labelText: 'Budget per unit *',
                            ),
                            items: controller.budgetBands
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              controller.setBudget(value);
                            },
                            validator: (value) =>
                                value == null ? 'Select a budget' : null,
                          ),
                        ),
                        TextFormField(
                          // initialValue: controller.deliveryDate.value != null
                          //     ? DateFormat('dd MMM yyyy')
                          //           .format(controller.deliveryDate.value!)
                          //     : 'Choose delivery date',
                          controller: controller.deliveryDateController,
                          focusNode: controller.deliveryDateFocus,
                          readOnly: true,
                          decoration: const InputDecoration(
                            label: Text('Choose delivery date'),
                            suffixIcon: Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                            ),
                          ),

                          onTap: () {
                            controller.pickDeliveryDate(context);
                          },
                          onChanged: (value) {
                            // controller.pickDeliveryDate(context);
                          },
                          validator: (value) =>
                              value == null ? 'Select a delivery date' : null,
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
                              title: Text(option),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primary,
                              onChanged: (selected) {
                                controller.toggleCustomisation(
                                  option,
                                  selected ?? false,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _textField(
                        controller.messageController,
                        'Additional message (optional)',
                        maxLines: 4,
                        focusNode: controller.messageFocus,
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
                                : controller.submitForm,
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
      padding: const EdgeInsets.only(bottom: 16),
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
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 10,
          // childAspectRatio: 1.2,
          mainAxisExtent: 70,
          children: fields,
        );
      },
    );
  }

  Widget _textField(
    TextEditingController textController,
    String label, {
    required FocusNode focusNode,
    FocusNode? nextNode,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isMobile = false,
  }) {
    return TextFormField(
      controller: textController,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      focusNode: focusNode,
      maxLength: isMobile ? 10 : 100,
      inputFormatters: isMobile
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        counterText: '',
      ),
      onFieldSubmitted: (value) {
        controller.fieldFocusChange(
          currentFocus: focusNode,
          nextFocus: nextNode,
        );
      },
      onEditingComplete: () {
        controller.fieldFocusChange(
          currentFocus: focusNode,
          nextFocus: nextNode,
        );
      },
      onSaved: (newValue) {
        controller.fieldFocusChange(
          currentFocus: focusNode,
          nextFocus: nextNode,
        );
      },
      onTapOutside: (event) {
        controller.fieldFocusChange(
          currentFocus: focusNode,
          nextFocus: nextNode,
        );
      },
    );
  }
}
