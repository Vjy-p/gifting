import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_pages.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/constants/constants.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/core/theme/app_theme.dart';
import 'package:gifting/core/theme/theme_controller.dart';
import 'package:gifting/core/widgets/restart_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await Supabase.initialize(
    url: Constants.supabaseUrl,
    publishableKey: Constants.supbasePublishableKey,
  );

  Get.put(ThemeController(), permanent: true);

  runApp(const RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;

    return Obx(
      () => GetMaterialApp(
        title: 'Gifting',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppRoutes.home,
        getPages: AppPages.pages,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.unknown,
          },
        ),
      ),
    );
  }
}
