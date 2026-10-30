import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_pages.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/constants/constants.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await Supabase.initialize(
    url: Constants.supabaseUrl,
    publishableKey: Constants.supbasePublishableKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gifting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
    );
  }
}
