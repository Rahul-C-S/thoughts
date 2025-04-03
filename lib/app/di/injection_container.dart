import 'package:get/get.dart';
import 'package:thoughts/app/controller/auth/auth_controller.dart';
import 'package:thoughts/app/database/database.dart';

Future<void> initDependencies()async{
  
  Get.put(Database());
  
  // Auth
  Get.put(AuthController(),);
  
  
  
  
}