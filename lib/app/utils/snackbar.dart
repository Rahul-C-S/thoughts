import 'package:get/get.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';

enum SnackbarType { info, warning, success, error }

void showSnackbar({
  required String title,
  required String message,
  int duration = 3,
  SnackbarType type = SnackbarType.info,
}) {
  Get.snackbar(
    title,
    message,
    duration: Duration(seconds: duration),
    backgroundColor:
        type == SnackbarType.success
            ? AppColors.success
            : type == SnackbarType.error
            ? AppColors.error
            : type == SnackbarType.info
            ? AppColors.info
            : AppColors.warning,
          isDismissible: true,
          snackPosition: SnackPosition.BOTTOM,
          
  );
}
