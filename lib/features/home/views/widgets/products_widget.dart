import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/features/catalogue/controllers/catalogue_controller.dart';
import 'package:gifting/features/catalogue/views/widgets/product_tile.dart';
import 'package:gifting/features/home/views/widgets/section_widget.dart';

class ProductsWidget extends StatelessWidget {
  const ProductsWidget({super.key, required this.controller});

  final CatalogueController controller;

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Most Requested Corporate Gifts',
      subtitle: 'Thoughtful products for every business occasion.',
      child: Obx(() {
        final products = controller.trendingProducts.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 700 ? 2 : 4;
            log('width ${constraints.maxWidth}');
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth < 600
                    ? 0.64
                    : constraints.maxWidth < 1000
                    ? 0.56
                    : 0.8,
              ),
              itemBuilder: (context, index) {
                return ProductTile(
                  product: products[index],
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.productDetails,
                      arguments: products[index],
                    );
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
