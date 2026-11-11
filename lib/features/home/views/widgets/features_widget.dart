import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.border),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 32,
        runSpacing: 20,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.$1, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                item.$2,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(
                delay: (index * 90).ms,
                duration: 450.ms,
                curve: Curves.easeOutCubic,
              )
              .slideY(
                begin: 0.15,
                end: 0,
                duration: 450.ms,
                curve: Curves.easeOutCubic,
              );
        }).toList(),
      ),
    );
  }
}
