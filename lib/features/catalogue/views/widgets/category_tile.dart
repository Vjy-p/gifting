import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
