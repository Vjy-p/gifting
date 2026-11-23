import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_pages.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/core/services/initial_bindings.dart';
import 'package:gifting/core/services/notification_service.dart';
import 'package:gifting/core/theme/app_theme.dart';
import 'package:gifting/core/theme/theme_controller.dart';
import 'package:gifting/core/widgets/restart_widget.dart';
import 'package:gifting/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialise();
  runApp(const RestartWidget(child: MyApp()));
}

Future initialise() async {
  await Future.wait([
    HiveService.init(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);
  await NotificationService.initialize();
  // await FirebaseAppCheck.instance.activate(
  //   providerAndroid: const AndroidDebugProvider(),
  //   providerApple: const AppleAppAttestProvider(),
  //   providerWeb: WebDebugProvider(),
  // );
  Get.put(ThemeController(), permanent: true);
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
        initialRoute: AppRoutes.landingPage,
        getPages: AppPages.pages,
        initialBinding: InitialBinding(),
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
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
