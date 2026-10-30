import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';

import '../../../catalogue/controllers/catalogue_controller.dart';

class BannerWidget extends GetView<CatalogueController> {
  const BannerWidget({super.key, required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CORPORATE GIFTING',
              style: TextStyle(
                color: AppColors.primary,
                letterSpacing: 2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Thoughtful Gifts.\nStronger Business\nRelationships.',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontSize: isMobile ? 26 : 50,
                height: 1.15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Personalised corporate gifts for teams, clients '
              'and partners, thoughtfully curated for every occasion.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.7,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.selectCategory(controller.categories.first);
                    Get.toNamed(AppRoutes.catalogue);
                  },
                  child: const Text('Explore Gifts'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.createEnquiry);
                  },
                  child: const Text('Request a Bulk Quote'),
                ),
              ],
            ),
          ],
        );

        final image = Container(
          height: isMobile ? 200 : 420,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.sage,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_giftcard, size: 76, color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'Thoughtfully curated gifts',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 64,
            vertical: isMobile ? 32 : 60,
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [image, const SizedBox(height: 32), content],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: content),
                    const SizedBox(width: 56),
                    Expanded(flex: 4, child: image),
                  ],
                ),
        );
      },
    );
  }
}
