import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:mess_prototype/controllers/auth_controller.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/app_settings_repository.dart';
import 'package:mess_prototype/screens/auth_screen.dart';

import 'package:mess_prototype/screens/main_screen.dart';
import 'package:mess_prototype/services/is_valid_values.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final controller = AuthController();
  final isValidValues = IsValidValues();

  String usernameError = '';
  String firstNameError = '';
  String emailError = '';
  String phoneError = '';

  bool get hasErrors => 
    usernameError.isNotEmpty ||
    firstNameError.isNotEmpty ||
    emailError.isNotEmpty ||
    phoneError.isNotEmpty;

  User? get currentUser {return context.read<UserProvider>().user;}

  bool get hasChanges {
    final user = currentUser;

    if (user == null) return false;

    final username = controller.username.trim();
    final firstName = controller.firstName.trim();
    final email = controller.email.trim();
    final phone = controller.phone.trim();

    return username.isNotEmpty && username != user.username ||
      firstName.isNotEmpty && firstName != (user.firstName ?? '') ||
      email.isNotEmpty && email != (user.email ?? '') ||
      phone.isNotEmpty && phone != (user.phone ?? '');
  }

  void _validateUsername() {
    final value = controller.username;

    if (value.isEmpty) {
      usernameError = '';
      return;
    }

    usernameError = isValidValues.username(value) ?? '';
  }

  void _validateFirstName() {
    firstNameError = isValidValues.firstName(controller.firstName) ?? '';
  }

  void _validateEmail() {
    final value = controller.email;

    if (value.isEmpty) {
      emailError = '';
      return;
    }

    emailError = isValidValues.email(value) ?? '';
  }

  void _validatePhone() {
    final value = controller.phone;

    if (value.isEmpty) {
      phoneError = '';
      return;
    }

    phoneError = isValidValues.phone(phoneFormatter) ?? '';
  }

  void _validateAll() {
    _validateUsername();
    _validateFirstName();
    _validateEmail();
    _validatePhone();
  }

  Map<String, String> _buildChanges(User user) {
    final changes = <String, String>{};

    final username = controller.username.trim();
    final firstName = controller.firstName.trim();
    final email = controller.email.trim();
    final phone = controller.phone.trim();

    if (username.isNotEmpty && username != user.username) {
      changes['username'] = username;
    }

    if (firstName.isNotEmpty && firstName != user.firstName) {
      changes['first_name'] = firstName;
    }
    
    if (email.isNotEmpty && email != (user.email ?? '')) {
      changes['email'] = email;
    }
    
    if (phone.isNotEmpty && phone != (user.phone ?? '')) {
      changes['phone'] = phone;
    }

    return changes;
  }

  bool loading = false;
  
  bool hovered = false;

  bool hidingPassword = true;

  final MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
    mask: '### ### ##-##',
    filter: {"#": RegExp(r'[0-9]')}
  );

  Future<void> register() async {
    setState(() {
      loading = true;
    });

    try {
      await context.read<UserProvider>().register(
        username: controller.username,
        firstName: controller.firstName,
        email: controller.email,
        phone: phoneFormatter.unmaskText(controller.phone),
        password: controller.password,
      );

      final settingsRepository = SettingsRepository();
      final settings = await settingsRepository.getAppSettings();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(settings: settings),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          Center(
            child: Container(
              width: screenWidth * 0.8,
              constraints: BoxConstraints(
                maxWidth: 900,
                minWidth: 400
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                    offset: Offset(0, 4),
                    blurRadius: 10
                  )
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Регистрация',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 16,),
                  TextField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      labelText: 'Имя пользователя',
                      labelStyle: TextStyle(
                        fontSize: 16
                      ),

                      hintText: 'example',
                      hintStyle: TextStyle(
                        fontSize: 16
                      ),
                      prefixText: '@',
                      
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  TextField(
                    controller: controller.firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      labelStyle: TextStyle(
                        fontSize: 16
                      ),
                      
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      labelText: 'Почта',
                      labelStyle: TextStyle(
                        fontSize: 16
                      ),
                      
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  TextField(
                    inputFormatters: [phoneFormatter],
                    keyboardType: TextInputType.phone,
                    controller: controller.phoneController,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      labelStyle: TextStyle(
                        fontSize: 16
                      ),

                      prefixText: '+7 ',
                      
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                    ),
                    onChanged: (value) => print(phoneFormatter.unmaskText(controller.phone)),
                  ),
                  SizedBox(height: 8,),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: hidingPassword,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidingPassword = !hidingPassword;
                          });
                        },
                        icon: hidingPassword
                          ? Icon(Icons.visibility_outlined)
                          : Icon(Icons.visibility_off_outlined)
                      ),
                      
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Spacer(),
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            hovered = true;
                          });
                        },
                        onExit: (event) {
                          setState(() {
                            hovered = false;
                          });
                        },
                        child: GestureDetector(
                          onTap: register,
                          child: AnimatedContainer(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: hovered
                                ? Colors.grey[400]
                                : Colors.grey[300],
                              borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: Text('Создать аккаунт'),
                          ),
                        ),
                      ),
                      Spacer()
                    ]
                  ),
                  SizedBox(height: 16,),
                  Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthScreen()
                            )
                          );
                        },

                        child: Column(
                          children: [
                            Text('Есть аккаунт? Войди!'),
                            SizedBox(height: 2,),
                            Container(
                              color: Colors.grey[500],
                              width: 125,
                              height: 1,
                            )
                          ]
                        ),
                      ),
                      Spacer(),
                    ],
                  )
                ],
              ),
            )
          ),
          Spacer()
        ]

        // child: Column(
        // )
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}