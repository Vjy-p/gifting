import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/theme_controller.dart';
import 'package:gifting/core/widgets/restart_widget.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  test('ThemeController toggles theme between light and dark', () {
    final controller = Get.put(ThemeController());

    // Explicitly set to light mode
    controller.setThemeMode(ThemeMode.light);
    expect(controller.themeMode, ThemeMode.light);
    expect(controller.isDarkMode, false);

    // Toggle to dark mode
    controller.toggleTheme();
    expect(controller.themeMode, ThemeMode.dark);
    expect(controller.isDarkMode, true);

    // Toggle back to light mode
    controller.toggleTheme();
    expect(controller.themeMode, ThemeMode.light);
    expect(controller.isDarkMode, false);
  });

  testWidgets('RestartWidget restarts the application widget tree', (tester) async {
    int buildCount = 0;

    await tester.pumpWidget(
      RestartWidget(
        child: Builder(
          builder: (context) {
            buildCount++;
            return const MaterialApp(
              home: Scaffold(
                body: Text('App Content'),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('App Content'), findsOneWidget);
    expect(buildCount, 1);

    // Trigger restart
    RestartWidget.restart();
    await tester.pumpAndSettle();

    // Rebuilt with a fresh tree
    expect(buildCount, 2);
    expect(find.text('App Content'), findsOneWidget);
  });
}
