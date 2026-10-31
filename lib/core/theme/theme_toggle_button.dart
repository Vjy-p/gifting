import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Tooltip(
        message: isDark
            ? 'Switch to Light Mode (Long-press for options)'
            : 'Switch to Dark Mode (Long-press for options)',
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: themeController.toggleTheme,
          onLongPress: () => _showThemeSelectionDialog(context, themeController),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                color: isDark ? AppColors.gold : AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showThemeSelectionDialog(
    BuildContext context,
    ThemeController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.light_mode_outlined),
                  title: const Text('Light'),
                  trailing: controller.themeMode == ThemeMode.light
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    controller.setThemeMode(ThemeMode.light);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark'),
                  trailing: controller.themeMode == ThemeMode.dark
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    controller.setThemeMode(ThemeMode.dark);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_brightness_outlined),
                  title: const Text('System Default'),
                  trailing: controller.themeMode == ThemeMode.system
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    controller.setThemeMode(ThemeMode.system);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
