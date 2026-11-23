import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';
import 'package:gifting/core/widgets/retry_widget.dart';
import 'package:gifting/core/widgets/shimmer_loading.dart';
import 'package:gifting/features/catalogue/views/widgets/bottom_sheet_filter_widget.dart';
import 'package:gifting/features/catalogue/views/widgets/web_filter_widget.dart';
import 'package:gifting/features/products/views/product_tile.dart';
import 'package:paginated_list/paginated_list.dart';

import '../../../app/routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../products/models/product_model.dart';
import '../controllers/catalogue_controller.dart';

class CatalogueScreen extends GetView<CatalogueController> {
  const CatalogueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tribe Green'),
        backgroundColor: AppColors.surface,
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
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            child: const Text('Home'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 900;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 2,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Corporate Gifts',
                              style: isMobile
                                  ? textTheme.bodyLarge
                                  : textTheme.headlineMedium,
                            ),
                            Text(
                              'Explore thoughtful gifts for teams, clients and events.',
                              style: isMobile
                                  ? textTheme.bodySmall
                                  : textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (isMobile)
                        Obx(
                          () => IconButton(
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              openBottomSheetFilterWidget(context, controller);
                            },
                            iconSize: 20,
                            icon: controller.hasActiveFilters.value
                                ? Badge(
                                    smallSize: 8,
                                    backgroundColor: Theme.of(context)
                                        .hintColor,
                                    child: const Icon(
                                      Icons.filter_alt,
                                      size: 20,
                                    ),
                                  )
                                : const Icon(Icons.filter_alt, size: 20),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: isMobile
                        ? productsWidget()
                        : Row(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 120,
                                  maxWidth: 280,
                                ),
                                child: WebFilterWidget(controller: controller),
                              ),
                              const VerticalDivider(),
                              Expanded(child: productsWidget()),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget productsWidget() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const CatalogueLoadingSkeleton();
      }

      if (controller.error.value) {
        return RetryWidget(onPressed: controller.loadProducts);
      }

      final products = controller.products;

      if (products.isEmpty) {
        return const Center(child: Text('No products found in this category.'));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1300
              ? 6
              : width >= 1000
              ? 4
              : width >= 650
              ? 3
              : width >= 400
              ? 2
              : 1;

          return columns == 1
              ? PaginatedList(
                  items: controller.products,
                  physics: const BouncingScrollPhysics(),
                  isRecentSearch: false,
                  loadingIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  onLoadMore: (v) {
                    controller.loadProducts(reset: false);
                  },
                  isLastPage: controller.isLastPage.value,
                  builder: (context, index) {
                    final ProductModel product = products[index];
                    return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ProductTile(
                              product: product,
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.productDetails,
                                  arguments: product,
                                );
                              },
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: ((index % 6) * 45).ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                )
              : PaginatedGrid(
                  items: controller.products,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: columns == 1 ? 1.3 : 0.68,
                  ),
                  loadingIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  onLoadMore: () async {
                    await controller.loadProducts(reset: false);
                  },
                  isLastPage: controller.isLastPage.value,
                  builder: (context, index) {
                    final ProductModel product = products[index];
                    return ProductTile(
                          product: product,
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.productDetails,
                              arguments: product,
                            );
                          },
                        )
                        .animate()
                        .fadeIn(
                          delay: ((index % 8) * 40).ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                );
        },
      );
    });
  }
}
