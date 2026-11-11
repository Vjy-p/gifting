import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key, required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      //  color: Theme.of(context).colorScheme.,
      color: AppColors.footerBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco_outlined, color: AppColors.gold, size: isMobile ? 20 : 24),
              const SizedBox(width: 8),
              Text(
                'TRIBE GREEN',
                style: TextStyle(
                  color: AppColors.darkDarkGreen,
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Thoughtful gifting for modern businesses.',
            style: TextStyle(
              color: AppColors.darkSecondaryText,
              fontSize: isMobile ? 12 : 14,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 24),
          Divider(
            color: AppColors.border.withValues(alpha: 0.25),
          ),
          SizedBox(height: isMobile ? 6 : 12),
          Text(
            'Corporate gifting • Custom branding • Bulk orders',
            style: TextStyle(
              color: AppColors.darkSecondaryText,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
