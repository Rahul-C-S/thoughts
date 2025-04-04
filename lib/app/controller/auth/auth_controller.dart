import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/config/routes/route_names.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';
import 'package:thoughts/app/database/db_constants.dart';
import 'package:thoughts/app/model/auth/user_model.dart';
import 'package:thoughts/app/database/database.dart';

class AuthController extends GetxController {
  final RxBool isAuthenticated = false.obs;
  final Rx<UserModel?> authUser = Rx<UserModel?>(null);
  final _db = Get.find<Database>();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () => _checkUserExists());
  }

  Future<void> _checkUserExists() async {
    try {
      final userList = await _db.readAll(DbConstants.userCollection);
      if (userList.isEmpty) {
        if (Get.context != null && Get.isSnackbarOpen == false) {
          Get.snackbar(
            'No account found!',
            'Please create account!',
            backgroundColor: AppColors.info,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        await Future.delayed(const Duration(milliseconds: 100));
        Get.offAndToNamed(RouteNames.signup);
      }
    } catch (e) {
      debugPrint('Error checking user: ${e.toString()}');
      if (Get.context != null && Get.isSnackbarOpen == false) {
        Get.snackbar(
          'Error',
          'Failed to check user data',
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = {
        DbConstants.name: name,
        DbConstants.email: email,
        DbConstants.password: password,
      };

      final userMap = await _db.create(DbConstants.userCollection, user);
      authUser.value = UserModel.fromMap(userMap);
      isAuthenticated.value = true;
      debugPrint('User created: ${userMap.toString()}');
      Get.snackbar(
        'Success',
        'Account has been created!',
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamedUntil(RouteNames.home, (route) => false);
    } catch (e, s) {
      debugPrint(s.toString());
      Get.snackbar(
        'Error',
        'Failed to signup!',
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> login(String password) async {
    try {
      final userList = (await _db.getCollection(DbConstants.userCollection));
      final userMap = userList.first;
      if (userMap[DbConstants.password] == password) {
        // Auth successful
        isAuthenticated.value = true;
        authUser.value = UserModel.fromMap(userMap);
        Get.snackbar(
          'Success',
          'Login success!',
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamedUntil(RouteNames.home, (route) => false);
        return;
      } else {
        // Auth failure
        Get.snackbar(
          'Error',
          'password doesn\'t match!',
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } catch (e, s) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );

      debugPrint(s.toString());
    }
  }
}
