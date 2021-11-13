import 'package:get/get.dart';

class ErrorHandler{
  void handleError(error){
    Get.defaultDialog(
      title: error
    );
  }
}