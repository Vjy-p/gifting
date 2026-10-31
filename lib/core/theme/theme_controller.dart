import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/core/widgets/restart_widget.dart';

class ThemeController extends GetxController {
  static ThemeController get to {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>();
    }
    return Get.put(ThemeController(), permanent: true);
  }

  static const String _themeModeKey = 'theme_mode';

  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPreferences();
  }

  void _loadThemeFromPreferences() {
    try {
      final box = HiveService.settingsBox;
      final savedMode = box.get(_themeModeKey, defaultValue: 'system');
      if (savedMode == 'dark') {
        _themeMode.value = ThemeMode.dark;
      } else if (savedMode == 'light') {
        _themeMode.value = ThemeMode.light;
      } else {
        _themeMode.value = ThemeMode.system;
      }
    } catch (_) {
      _themeMode.value = ThemeMode.system;
    }
  }

  void toggleTheme() {
    if (isDarkMode) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    final String modeString = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    try {
      HiveService.settingsBox.put(_themeModeKey, modeString);
    } catch (_) {}
    Get.changeThemeMode(mode);

    // Restart the entire app so all containers, cards, and cached states rebuild cleanly
    RestartWidget.restart();
  }
}
