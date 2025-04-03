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
      Get.snackbar(
        'Success',
        'Account has been created!',
        backgroundColor: AppColors.success,
        duration: Durations.extralong4,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamedUntil(RouteNames.home, (route) => false);
    } catch (e, s) {
      debugPrint(s.toString());
      Get.snackbar(
        'Error',
        'Failed to signup!',
        backgroundColor: AppColors.error,
        duration: Durations.extralong4,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    final userList = (await _db.where(
      DbConstants.userCollection,
      DbConstants.email,
      email,
    ));
    if (userList.isEmpty) {
      Get.snackbar(
        'Error',
        'No user found!',
        backgroundColor: AppColors.error,
        duration: Durations.extralong4,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final userMap = userList.first;
    if (userMap[DbConstants.password] == password) {
      // Auth successful
      isAuthenticated.value = true;
      authUser.value = UserModel.fromMap(userMap);
      Get.offNamedUntil(RouteNames.home, (route) => false);
      Get.snackbar(
        'Success',
        'Login success!',
        backgroundColor: AppColors.success,
        duration: Durations.extralong4,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Auth failure
      Get.snackbar(
        'Error',
        'password doesn\'t match!',
        backgroundColor: AppColors.error,
        duration: Durations.extralong4,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
  }
}
