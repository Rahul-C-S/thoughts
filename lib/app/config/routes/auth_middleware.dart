import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/config/routes/route_names.dart';
import 'package:thoughts/app/controller/auth/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    bool isAuthenticated = checkUserLoginStatus();

    if (!isAuthenticated) {
      return const RouteSettings(
        name: RouteNames.login,
      ); 
    }
    return null;
  }

  bool checkUserLoginStatus() {
    final authCtrl = Get.find<AuthController>();
    return authCtrl.isAuthenticated.value;
  }
}
