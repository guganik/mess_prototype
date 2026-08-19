import 'package:flutter/material.dart';

class AuthController {
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final loginController = TextEditingController();

  String get username => usernameController.text.trim();
  String get firstName => firstNameController.text.trim();
  String get email => emailController.text.trim();
  String get password => passwordController.text.trim();
  String get phone => phoneController.text.trim();
  String get login => loginController.text.trim();

  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    loginController.dispose();
  }
}