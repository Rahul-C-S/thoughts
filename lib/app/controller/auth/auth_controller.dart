import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/config/routes/route_names.dart';
import 'package:thoughts/app/database/db_constants.dart';
import 'package:thoughts/app/model/auth/user_model.dart';
import 'package:thoughts/app/database/database.dart';
import 'package:thoughts/app/utils/snackbar.dart';

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
          showSnackbar(
            title: 'No account found!',
            message: 'Please create account!',
          );
        }
        await Future.delayed(const Duration(milliseconds: 100));
        Get.offAndToNamed(RouteNames.signup);
      }
    } catch (e) {
      debugPrint('Error checking user: ${e.toString()}');
      if (Get.context != null && Get.isSnackbarOpen == false) {
        showSnackbar(
          title: 'Error',
          message: 'Failed to check user data',
          type: SnackbarType.error,
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

      showSnackbar(
        title: 'Success',
        message: 'Account has been created!',
        type: SnackbarType.success,
      );
      Get.offNamedUntil(RouteNames.home, (route) => false);
    } catch (e, s) {
      debugPrint(s.toString());
      showSnackbar(
        title: 'Error',
        message: 'Failed to signup!',
        type: SnackbarType.error,
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
        showSnackbar(
          title: 'Success',
          message: 'Login success!',
          type: SnackbarType.success,
        );
        Get.offNamedUntil(RouteNames.home, (route) => false);
        return;
      } else {
        // Auth failure
        showSnackbar(
          title: 'Error',
          message: 'password doesn\'t match!',
          type: SnackbarType.error,
        );
        return;
      }
    } catch (e, s) {
      showSnackbar(
        title: 'Error',
        message: 'Please signup!',
        type: SnackbarType.error,
      );
      debugPrint(s.toString());
      _db.deleteAll();
      Get.offNamed(RouteNames.signup);
    }
  }
}
