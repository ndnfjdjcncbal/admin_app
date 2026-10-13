import 'package:adminapp/core/constants/app_color/Colors.dart';
import 'package:adminapp/core/routes/app_routes.dart';
import 'package:adminapp/core/services/notifications/notification_service.dart';
import 'package:adminapp/core/services/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  initDependencies();
  await sl.allReady();

  await sl<NotificationService>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRoutes.navigatorKey,
      title: 'Store Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.backgroundGrey,
        ),
        scaffoldBackgroundColor: AppColors.backgroundGrey,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
