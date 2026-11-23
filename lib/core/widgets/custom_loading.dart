import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({
    super.key,
    double? size,
    double? dimension,
    this.color,
  }) : size = dimension ?? size ?? 24.0;

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}
