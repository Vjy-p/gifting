import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/features/catalogue/controllers/catalogue_controller.dart';
import 'package:gifting/features/catalogue/views/widgets/category_tile.dart';
import 'package:gifting/features/home/views/widgets/section_widget.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  static const categories = [
    ('Drinkware', Icons.local_drink_outlined),
    ('Apparel', Icons.checkroom_outlined),
    ('Work Essentials', Icons.work_outline),
    ('Wellness', Icons.spa_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Collections Crafted for Modern Workplaces',
      subtitle: 'Explore our thoughtfully curated gifting categories.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 700 ? 2 : 4;
          // log("width ${constraints.maxWidth}");
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: constraints.maxWidth < 600
                  ? 1
                  : constraints.maxWidth < 1140
                  ? 0.9
                  : 1.5,
            ),
            itemBuilder: (context, index) {
              final item = categories[index];
              return CategoryTile(
                title: item.$1,
                icon: item.$2,
                onTap: () {
                  final catalogueController = Get.find<CatalogueController>();
                  catalogueController.clearFilters();
                  catalogueController.selectCategory(item.$1);
                  Get.toNamed(AppRoutes.catalogue);
                },
              );
            },
          );
        },
      ),
    );
  }
}
