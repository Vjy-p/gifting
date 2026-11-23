import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/theme_controller.dart';

class AppColors {
  AppColors._();

  static const Color lightPrimary = Color(0xFF13543E);
  static const Color lightDarkGreen = Color(0xFF0B2E21);
  static const Color lightSage = Color(0xFFE5EFE9);
  static const Color lightBackground = Color(0xFFFAF9F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF16231C);
  static const Color lightSecondaryText = Color(0xFF5A6C62);
  static const Color lightBorder = Color(0xFFDFE7E1);
  static const Color lightGold = Color(0xFFC79838);
  static const Color lightWhite = Color(0xFFFFFFFF);
  static const Color lightFooter = Color(0xFF0C2419);

  static const Color darkPrimary = Color(0xFF38D69A);
  static const Color darkDarkGreen = Color(0xFFE5F5EE);
  static const Color darkSage = Color(0xFF172B21);
  static const Color darkBackground = Color(0xFF0C120F);
  static const Color darkSurface = Color(0xFF141D19);
  static const Color darkText = Color(0xFFF3F7F5);
  static const Color darkSecondaryText = Color(0xFF94A99F);
  static const Color darkBorder = Color(0xFF22352B);
  static const Color darkGold = Color(0xFFF5C762);
  static const Color darkWhite = Color(0xFFFFFFFF);
  static const Color darkFooter = Color(0xFF070B09);
  static const Color red = Color(0xFFD63B3B);

  static bool get isDark {
    if (Get.isRegistered<ThemeController>()) {
      return ThemeController.to.isDarkMode;
    }
    return false;
  }

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

  static Color get elevatedSurface =>
      isDark ? const Color(0xFF1C2722) : const Color(0xFFF4F8F5);
  static Color get chipBackground => sage;
  static Color get accentGold => gold;

  static Color get surfaceElevated => elevatedSurface;
  static Color get surfacePrimary => surface;
  static Color get borderSubtle => border;
  static Color get textPrimary => text;
  static Color get textSecondary => secondaryText;
  static Color get backgroundPrimary => background;
  static Color get darkBlue => const Color(0xFF0D251C);
  static Color get textMuted => secondaryText;
  static Color get actionPrimary => primary;
  static Color get backgroundSecondary => elevatedSurface;

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
