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
      color: AppColors.darkGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRIBE GREEN',
            style: TextStyle(
              color: AppColors.background,
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Thoughtful gifting for modern businesses.',
            style: TextStyle(
              color: AppColors.sage,
              fontSize: isMobile ? 12 : 14,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 24),
          Divider(color: AppColors.border.withValues(alpha: 0.2)),
          SizedBox(height: isMobile ? 6 : 12),
          Text(
            'Corporate gifting • Custom branding • Bulk orders',
            style: TextStyle(
              color: AppColors.sage,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
