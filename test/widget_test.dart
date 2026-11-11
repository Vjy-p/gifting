import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/app_theme.dart';
import 'package:gifting/core/theme/theme_controller.dart';
import 'package:gifting/core/widgets/restart_widget.dart';
import 'package:gifting/core/widgets/shimmer_loading.dart';
import 'package:gifting/features/splash/views/splash_screen.dart';

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

  test('AppTheme builds valid light and dark themes with modern classic palette', () {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    expect(light.brightness, Brightness.light);
    expect(light.colorScheme.primary, AppColors.lightPrimary);
    expect(light.scaffoldBackgroundColor, AppColors.lightBackground);
    expect(light.cardTheme.color, AppColors.lightSurface);

    expect(dark.brightness, Brightness.dark);
    expect(dark.colorScheme.primary, AppColors.darkPrimary);
    expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
    expect(dark.cardTheme.color, AppColors.darkSurface);
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

  testWidgets('DashboardLoadingSkeleton renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardLoadingSkeleton(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(DashboardLoadingSkeleton), findsOneWidget);
    expect(find.byType(ShimmerBox), findsWidgets);
  });

  testWidgets('SplashScreen displays brand and loading indicator', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const SplashScreen()),
          GetPage(
            name: AppRoutes.signup,
            page: () => const Scaffold(body: Text('Signup Screen')),
          ),
          GetPage(
            name: AppRoutes.login,
            page: () => const Scaffold(body: Text('Login Screen')),
          ),
          GetPage(
            name: AppRoutes.home,
            page: () => const Scaffold(body: Text('Home Screen')),
          ),
        ],
      ),
    );

    // Initial pump
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('TRIBE GREEN'), findsOneWidget);
    expect(find.text('Thoughtful Corporate Gifting'), findsOneWidget);
    expect(find.text('Curating gifts...'), findsOneWidget);

    // Advance splash delay timer and handle navigation
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(find.text('Signup Screen'), findsOneWidget);
  });
}
