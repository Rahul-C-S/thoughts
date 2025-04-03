import 'package:get/route_manager.dart';
import 'package:thoughts/app/config/routes/auth_middleware.dart';
import 'package:thoughts/app/config/routes/route_names.dart';
import 'package:thoughts/app/view/auth/pages/login_page.dart';
import 'package:thoughts/app/view/auth/pages/signup_page.dart';
import 'package:thoughts/app/view/home/home_page.dart';

class AppRoutes {
  static List<GetPage> routes = [
    ...AppRoutes.protectedRoutes,
    ...AppRoutes.publicRoutes,
  ];

  // Routes without authentication
  static List<GetPage> get publicRoutes => [
    GetPage(name: RouteNames.login, page: () => LoginPage()),
    GetPage(name: RouteNames.signup, page: () => SignupPage()),
  ];

  // Routes with authentication
  static List<GetPage> get protectedRoutes => [
    GetPage(
      name: RouteNames.home,
      page: () => HomePage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
