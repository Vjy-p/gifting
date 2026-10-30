import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';

class FeaturesWidget extends StatelessWidget {
  const FeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.inventory_2_outlined, 'Bulk Order Support'),
      (Icons.draw_outlined, 'Custom Branding'),
      (Icons.card_giftcard_outlined, 'Personalised Gifting'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.border),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 32,
        runSpacing: 20,
        children: items.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.$1, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                item.$2,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
