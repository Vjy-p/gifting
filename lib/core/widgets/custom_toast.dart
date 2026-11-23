import 'package:flutter/painting.dart';
import 'package:get/get.dart';

SnackbarController? customToast({required String title, required String text}) {
  if (Get.overlayContext == null) {
    return null;
  }
  return Get.snackbar(
    title,
    text,
    snackPosition: SnackPosition.BOTTOM,
    padding: const EdgeInsets.all(16),
    maxWidth: 900,
  );
}
