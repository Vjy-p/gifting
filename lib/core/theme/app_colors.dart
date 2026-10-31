import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/theme_controller.dart';

class AppColors {
  AppColors._();

  // --- Light Palette ---
  static const Color lightPrimary = Color(0xFF245C45);
  static const Color lightDarkGreen = Color(0xFF193F30);
  static const Color lightSage = Color(0xFFDDE9DF);
  static const Color lightBackground = Color(0xFFFAF9F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF252925);
  static const Color lightSecondaryText = Color(0xFF6B716B);
  static const Color lightBorder = Color(0xFFE5E7E2);
  static const Color lightGold = Color(0xFFC5A46D);
  static const Color lightWhite = Color(0xFFFFFFFF);
  static const Color lightFooter = Color(0xFF193F30);

  // --- Dark Palette ---
  static const Color darkPrimary = Color(0xFF48B682);
  static const Color darkDarkGreen = Color(0xFFE3EFE8);
  static const Color darkSage = Color(0xFF1E3227);
  static const Color darkBackground = Color(0xFF111714);
  static const Color darkSurface = Color(0xFF1A231E);
  static const Color darkText = Color(0xFFF1F5F2);
  static const Color darkSecondaryText = Color(0xFF9CAB9F);
  static const Color darkBorder = Color(0xFF29382F);
  static const Color darkGold = Color(0xFFDFBF84);
  static const Color darkWhite = Color(0xFFFFFFFF);
  static const Color darkFooter = Color(0xFF0C130F);
  static const Color red = Color(0xFFB42318);

  // --- Dynamic Mode Check ---
  static bool get isDark {
    if (Get.isRegistered<ThemeController>()) {
      return ThemeController.to.isDarkMode;
    }
    return false;
  }

  // --- Theme-Aware Dynamic Getters ---
  static Color get primary => isDark ? darkPrimary : lightPrimary;
  static Color get darkGreen => isDark ? darkDarkGreen : lightDarkGreen;
  static Color get sage => isDark ? darkSage : lightSage;
  static Color get background => isDark ? darkBackground : lightBackground;
  static Color get surface => isDark ? darkSurface : lightSurface;
  static Color get text => isDark ? darkText : lightText;
  static Color get secondaryText =>
      isDark ? darkSecondaryText : lightSecondaryText;
  static Color get border => isDark ? darkBorder : lightBorder;
  static Color get gold => isDark ? darkGold : lightGold;
  static Color get white => isDark ? darkWhite : lightWhite;
  static Color get footerBackground => isDark ? darkFooter : lightFooter;

  /// Helper to get colors based on a specific BuildContext
  static Color ofPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkPrimary
      : lightPrimary;
  static Color ofBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : lightBackground;
  static Color ofSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkSurface
      : lightSurface;
}
