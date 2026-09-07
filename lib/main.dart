import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

// NOTE: Firebase initialization added in a later step once
// firebase_options.dart is generated manually (same approach used in
// Tasks 1-4 due to a known Windows CLI issue).
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final themeController = Get.put(ThemeController());

  runApp(InternGrowHospitalApp(themeController: themeController));
}

class InternGrowHospitalApp extends StatelessWidget {
  final ThemeController themeController;

  const InternGrowHospitalApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'InternGrow Hospital',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      );
    });
  }
}