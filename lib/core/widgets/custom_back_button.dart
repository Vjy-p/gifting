import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onPressed, this.color});

  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: color ?? AppColors.text,
        size: 20,
      ),
      onPressed: onPressed ?? () => Get.back(),
    );
  }
}
