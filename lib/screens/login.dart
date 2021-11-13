import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_note/controller/auth_controller.dart';


class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Login with google'),
          onPressed: (){
            authController.signInWithGoogle();
          },
        ),
      ),
    );
  }
}
