import 'package:get/get.dart';
import 'package:thoughts/app/controller/auth/auth_controller.dart';
import 'package:thoughts/app/controller/home/home_controller.dart';
import 'package:thoughts/app/controller/note/note_controller.dart';
import 'package:thoughts/app/controller/quote/quote_controller.dart';
import 'package:thoughts/app/database/database.dart';

Future<void> initDependencies() async {
  Get.put(Database());

  Get.put(AuthController());
  Get.put(QuoteController());
  Get.put(HomeController());
  Get.put(NoteController());
}
