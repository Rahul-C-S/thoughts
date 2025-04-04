import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:thoughts/app/config/theme/app_theme.dart';
import 'package:thoughts/app/di/injection_container.dart';
import 'package:thoughts/app/config/routes/app_routes.dart';
import 'package:thoughts/app/config/routes/route_names.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      getPages: AppRoutes.routes,
      initialRoute: RouteNames.home,
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
    );
  }
}
