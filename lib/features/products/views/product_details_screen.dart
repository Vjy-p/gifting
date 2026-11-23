import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/services/common_services.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';
import 'package:gifting/core/widgets/custom_back_button.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';

import '../controllers/product_details_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailsController>(
      builder: (controller) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              controller.recordEnquiryOnExit();
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              leading: CustomBackButton(
                onPressed: () {
                  controller.recordEnquiryOnExit();
                  Get.back();
                },
              ),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow
                .withValues(alpha: 0.1),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLow
                      .withValues(alpha: 0.1),
                ),
              ),
            ),
            title: const Text('Product Details'),
            actions: [
              Obx(() {
                final cartController = Get.isRegistered<CartController>()
                    ? Get.find<CartController>()
                    : Get.put(CartController());
                final count = cartController.cart.length;
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: IconButton(
                    tooltip: 'Cart',
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () => Get.toNamed(AppRoutes.cart),
                  ),
                );
              }),
              const ThemeToggleButton(),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 750;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 28,
                  isMobile
                      ? kToolbarHeight +
                            MediaQuery.of(context).padding.top / 1.6
                      : kToolbarHeight + 10,
                  isMobile ? 16 : 28,
                  isMobile ? 16 : 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1150),
                    child: isMobile
                        ? _buildMobileLayout(
                            context: context,
                            controller: controller,
                          )
                        : _buildDesktopLayout(
                            context: context,
                            controller: controller,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
  }

  Widget _buildMobileLayout({
    required BuildContext context,
    required ProductDetailsController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        productImage(
              context: context,
              imageUrl: controller.product.imageUrl ?? '',
            )
            .animate()
            .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
            .scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 24),
        _productInformation(context: context, controller: controller)
            .animate()
            .fadeIn(delay: 150.ms, duration: 500.ms, curve: Curves.easeOutCubic)
            .slideY(
              begin: 0.08,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  Widget _buildDesktopLayout({
    required BuildContext context,
    required ProductDetailsController controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child:
              productImage(
                    context: context,
                    imageUrl: controller.product.imageUrl ?? '',
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
        ),
        const SizedBox(width: 48),
        Expanded(
          child: _productInformation(context: context, controller: controller)
              .animate()
              .fadeIn(
                delay: 150.ms,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              )
              .slideY(
                begin: 0.08,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
      ],
    );
  }

  Widget productImage({
    required BuildContext context,
    required String imageUrl,
  }) {
    if (imageUrl.isEmpty) {
      return Center(
        child: Icon(Icons.card_giftcard, size: 56, color: AppColors.primary),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorWidget: (context, error, stackTrace) {
            return Center(
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

  Widget _productInformation({
    required BuildContext context,
    required ProductDetailsController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.product.category.toUpperCase(),
          style: TextStyle(
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
          '${controller.product.price} / unit',
          style: TextStyle(
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
        Column(
          children: controller.product.customisations.map((option) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              title: Text(option),
              value: controller.product.selectedCustomisations.contains(option),
              onChanged: (_) {
                controller.toggleCustomisation(option);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Number of Units'),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton.outlined(
              onPressed: controller.decreaseQuantity,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            Text(
              '${controller.product.quantity}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            IconButton.outlined(
              onPressed: controller.increaseQuantity,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Final pricing depends on order quantity and customisation.',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
        ),
        const SizedBox(height: 24),
        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       Get.toNamed(
        //         AppRoutes.createEnquiry,
        //         arguments: {
        //           'product': jsonEncode(controller.product),
        //           'quantity': controller.quantity.value,
        //           'customisations': controller.customisations.toList(),
        //         },
        //       );
        //     },
        //     child: const Text('Enquire About This Product'),
        //   ),
        // ),
        cartButton(context: context, controller: controller),
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

  Widget cartButton({
    required BuildContext context,
    required ProductDetailsController controller,
  }) {
    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    return Obx(() {
      final bool isAdded = cartController.cart.any(
        (e) => e.id == controller.product.id,
      );
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: isAdded
            ? ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.cart);
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Go to Cart'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: () {
                  cartController.updateCart(product: controller.product);
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
      );
    });
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
