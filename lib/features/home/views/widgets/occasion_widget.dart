import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/catalogue/controllers/catalogue_controller.dart';
import 'package:gifting/features/home/views/widgets/section_widget.dart';

class OccasionWidget extends StatelessWidget {
  const OccasionWidget({super.key, required this.occasions});

  final List<(String, IconData)> occasions;

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Gifting for Every Occasion',
      subtitle: 'Find the right gift for every business milestone.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 700 ? 2 : 3;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: occasions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: constraints.maxWidth < 550 ? 1.1 : 1.7,
            ),
            itemBuilder: (context, index) {
              final item = occasions[index];

              return InkWell(
                onTap: () {
                  final catalogueController = Get.find<CatalogueController>();
                  catalogueController.clearFilters();
                  catalogueController.toggleOccasion(occasions[index].$1);
                  Get.toNamed(AppRoutes.catalogue);
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$2, color: AppColors.primary, size: 30),
                      const SizedBox(height: 12),
                      Text(
                        item.$1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
