import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/features/home/views/widgets/section_widget.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:gifting/features/products/views/product_tile.dart';

class ProductsWidget extends StatelessWidget {
  const ProductsWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.products,
  });
  final String title;
  final String subTitle;
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: title,
      subtitle: subTitle,
      child: SizedBox(
        height: 280,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: products.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 170,
              child: ProductTile(
                product: products[index],
                onTap: () {
                  Get.toNamed(
                    AppRoutes.productDetails,
                    arguments: products[index],
                  );
                },
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 10);
          },
        ),
      ),
    );
  }
}
