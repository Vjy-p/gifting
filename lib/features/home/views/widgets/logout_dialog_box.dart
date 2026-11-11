import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/authentication/services/auth_services.dart';

Future<dynamic> openLogoutDialogBox() {
  return Get.generalDialog(
    pageBuilder: (context, animation, secondaryAnimation) {
      return SimpleDialog(
        title: const Text(
          'Are you sure you want to sign out?',
          textAlign: TextAlign.center,
        ),
        titlePadding: const EdgeInsetsGeometry.fromLTRB(24, 24, 24, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        alignment: Alignment.center,
        children: [
          Row(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    AppColors.secondaryText,
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await AuthServices().logout();
                  // if (Get.isRegistered<AuthController>()) {
                  //   Get.delete<AuthController>(force: true);
                  // }
                  // if (Get.isRegistered<EnquiryController>()) {
                  //   Get.delete<EnquiryController>(force: true);
                  // }
                  // if (Get.isRegistered<CatalogueController>()) {
                  //   Get.delete<CatalogueController>(force: true);
                  // }
                  Get.offAllNamed(AppRoutes.landingPage);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ],
      );
    },
  );
}
