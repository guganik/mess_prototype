import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:mess_prototype/controllers/auth_controller.dart';
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
  String passwordError = '';
  String passwordCurrectlyError = '';

  bool get hasErrors => 
    usernameError.isNotEmpty ||
    firstNameError.isNotEmpty ||
    emailError.isNotEmpty ||
    phoneError.isNotEmpty ||
    passwordError.isNotEmpty ||
    passwordCurrectlyError.isNotEmpty;

  void _validateUsername() {
    final value = controller.username;

    if (value.isEmpty) {
      usernameError = 'Имя пользователя не может быть пустым';
      return;
    }

    usernameError = isValidValues.username(value) ?? '';
  }

  void _validateFirstName() {
    final value = controller.firstName;

    if (value.isEmpty) {
      firstNameError = 'Имя не может быть пустым';
      return;
    }

    firstNameError = isValidValues.firstName(value) ?? '';
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

  void _validatePassword() {
    final value = controller.password;

    if (value.isEmpty) {
      passwordError = 'Пароль не может быть пустым';
      return;
    }

    passwordError = isValidValues.password(value) ?? '';
  }

  void _validateAll() {
    _validateUsername();
    _validateFirstName();
    _validateEmail();
    _validatePhone();
    _validatePassword();
  }

  bool loading = false;
  
  bool hovered = false;

  bool hidingPassword = true;

  final MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
    mask: '### ### ##-##',
    filter: {"#": RegExp(r'[0-9]')}
  );

  Future<void> register() async {
    if (loading) return;

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
      print(e);
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
                Container(
                  padding: EdgeInsets.all(16),
                  width: screenWidth * 0.6,
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    minWidth: 400
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(75, 75, 75, 75),
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          
                          errorText: usernameError.isNotEmpty
                            ? usernameError
                            : null,
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _validateUsername();
                          });
                        },
                      ),
                      SizedBox(height: 8,),
                      TextField(
                        controller: controller.firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Имя',
                          labelStyle: TextStyle(
                            fontSize: 16
                          ),
                          
                          errorText: firstNameError.isNotEmpty
                            ? firstNameError
                            : null,
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _validateFirstName();
                          });
                        },
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
                          
                          errorText: passwordError.isNotEmpty
                            ? passwordError
                            : null,
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _validatePassword();
                          });
                        },
                      ),
                      SizedBox(height: 8,),
                      TextField(
                        controller: controller.passwordCurrectlyController,
                        obscureText: hidingPassword,
                        decoration: InputDecoration(
                          labelText: 'Подтверждение пароля',
                          
                          errorText: passwordCurrectlyError.isNotEmpty
                            ? passwordCurrectlyError
                            : null,
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (controller.password != value) {
                              passwordCurrectlyError = 'Пароли не совпадают';
                            } else {
                              passwordCurrectlyError = '';
                            }
                          });
                        },
                      ),
                      SizedBox(height: 8,),
                      Text(
                        'Обязательные поля',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                Container(
                  padding: EdgeInsets.all(16),
                  width: screenWidth * 0.6,
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    minWidth: 400
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(75, 75, 75, 75),
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          labelText: 'Почта',
                          labelStyle: TextStyle(
                            fontSize: 16
                          ),
                          
                          errorText: emailError.isNotEmpty
                            ? emailError
                            : null,
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _validateEmail();
                          });
                        },
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
                          
                          errorText: phoneError.isNotEmpty
                            ? phoneError
                            : null,
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _validatePhone();
                          });
                        },
                      ),
                      SizedBox(height: 8,),
                      Text(
                        'Необязательные поля',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16,),
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
                        onTap: () {
                          setState(_validateAll);
                          if (!hasErrors) {
                            register;
                          }
                        },
                        child: AnimatedContainer(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: hasErrors
                              ? Colors.grey[300]
                              : hovered
                                ? Colors.grey[500]
                                : Colors.grey[400],
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
          ),
          Spacer()
        ]
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}