import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/widgets/retry_widget.dart';
import 'package:gifting/features/catalogue/views/widgets/bottom_sheet_filter_widget.dart';
import 'package:gifting/features/catalogue/views/widgets/product_tile.dart';
import 'package:gifting/features/catalogue/views/widgets/web_filter_widget.dart';

import '../../../app/routes/app_routes.dart';
import '../controllers/catalogue_controller.dart';
import '../models/product_model.dart';

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
                        IconButton(
                          style: ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            openBottomSheetFilterWidget(context, controller);
                          },
                          iconSize: 20,
                          icon: Icon(Icons.filter_alt, size: 20),
                        ),
                    ],
                  ),
                  if (isMobile) selectedFilters(),
                  Expanded(
                    child: isMobile
                        ? productsWidget()
                        : Row(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 120,
                                  maxWidth: 280,
                                ),
                                child: WebFilterWidget(controller: controller),
                              ),
                              VerticalDivider(),
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
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
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

          return GridView.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: columns == 1 ? 1.35 : 0.68,
            ),
            itemBuilder: (context, index) {
              final ProductModel product = products[index];

              return ProductTile(
                product: product,
                onTap: () {
                  Get.toNamed(AppRoutes.productDetails, arguments: product);
                },
              );
            },
          );
        },
      );
    });
  }

  Widget selectedFilters() {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        runAlignment: WrapAlignment.start,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          if (controller.selectedCategory.isNotEmpty) ...[
            ChoiceChip(
              label: Text(controller.selectedCategory.value),
              selected: true,
              onSelected: (_) =>
                  controller.selectCategory(controller.selectedCategory.value),
              selectedColor: AppColors.sage,
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: AppColors.primary),
            ),
          ],
          ...controller.selectedCustomisations.map(
            (e) => ChoiceChip(
              label: Text(e),
              selected: true,
              onSelected: (_) => controller.toggleCustomisation(e),
              selectedColor: AppColors.sage,
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: AppColors.primary),
            ),
          ),
          ...controller.selectedOccasions.map(
            (e) => ChoiceChip(
              label: Text(e),
              selected: true,
              onSelected: (_) => controller.toggleOccasion(e),
              selectedColor: AppColors.sage,
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: AppColors.primary),
            ),
          ),
          // if (controller.selectedPrice.value.start != null) ...[
          //   ChoiceChip(
          //     label: Text(controller.selectedCategory.value),
          //     selected: true,
          //     onSelected: (_) =>
          //         controller.selectCategory(controller.selectedCategory.value),
          //     selectedColor: AppColors.sage,
          //     labelStyle: TextStyle(
          //       color: AppColors.primary,
          //       fontWeight: FontWeight.w600,
          //     ),
          //     side: BorderSide(color: AppColors.primary),
          //   ),
          // ],
        ],
      ),
    );
  }
}
