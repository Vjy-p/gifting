import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/services/common_services.dart';
import 'package:gifting/core/theme/app_colors.dart';

import '../controllers/product_details_controller.dart';

class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 20 : 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1150),
                child: isMobile
                    ? _buildMobileLayout(context)
                    : _buildDesktopLayout(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        productImage(),
        const SizedBox(height: 24),
        _productInformation(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: productImage()),
        const SizedBox(width: 48),
        Expanded(child: _productInformation(context)),
      ],
    );
  }

  Widget productImage() {
    final String imageUrl = controller.product.imageUrl ?? "";
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.card_giftcard, size: 56, color: AppColors.primary),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sage,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorWidget: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.card_giftcard_outlined,
                size: 96,
                color: AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _productInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.product.category.toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            letterSpacing: 1.5,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          controller.product.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          '${controller.product.priceRange} / unit',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          controller.product.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        _sectionTitle('Suitable Occasions'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.product.occasions.map((occasion) {
            return Chip(
              label: Text(occasion),
              backgroundColor: AppColors.sage,
              side: BorderSide.none,
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        _sectionTitle('Customisation Available'),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            children: controller.product.customisations.map((option) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: Text(option),
                value: controller.customisations.contains(option),
                onChanged: (_) {
                  controller.toggleCustomisation(option);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Number of Units'),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              IconButton.outlined(
                onPressed: controller.decreaseQuantity,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              Text(
                '${controller.quantity.value}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              IconButton.outlined(
                onPressed: controller.increaseQuantity,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Final pricing depends on order quantity and customisation.',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(
                AppRoutes.createEnquiry,
                arguments: {
                  'product': controller.product,
                  'quantity': controller.quantity.value,
                  'customisations': controller.customisations.toList(),
                },
              );
            },
            child: const Text('Enquire About This Product'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              CommonServices().openWhatsApp(products: [controller.product]);
            },
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Chat on WhatsApp'),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
