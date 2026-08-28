import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:mess_prototype/controllers/auth_controller.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/app_settings_repository.dart';
import 'package:mess_prototype/screens/register_screen.dart';

import 'package:mess_prototype/screens/main_screen.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final controller = AuthController();

  bool loading = false;
  
  bool hovered = false;

  bool hidingPassword = true;

  final MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
    mask: '### ### ##-##',
    filter: {"#": RegExp(r'[0-9]')}
  );

  String? errorText;

  Future<void> authorization() async {
    setState(() {
      loading = true;
      errorText = null;
    });

    try {
      await context.read<UserProvider>().login(
        username: controller.username,
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorText = 'Пользователь не найден';
      });
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
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          Center(
            child: Container(
              width: screenWidth * 0.8,
              padding: EdgeInsets.all(16*4),
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
                  TextField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      labelText: 'Имя пользователя',
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
                    controller: controller.passwordController,
                    obscureText: hidingPassword,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      labelStyle: TextStyle(
                        fontSize: 16
                      ),
                      
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
                    )
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
                          onTap: () {
                            if (controller.username != '' && controller.password != '') {
                              authorization();
                            } else {
                              setState(() {
                                errorText = 'Не все поля заполнены';
                              });
                            }
                          },
                          child: AnimatedContainer(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: hovered
                                ? Colors.grey[400]
                                : Colors.grey[300],
                              borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: Text('Войти'),
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
                              builder: (context) => RegisterScreen()
                            )
                          );
                        },

                        child: Column(
                          children: [
                            Text('Нет аккаунта? Создай!'),
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
                  ),
                  SizedBox(height: 8,),
                  errorText == null
                    ? SizedBox()
                    : Text(
                        errorText!,
                        style: TextStyle(
                          color: Colors.redAccent[400]
                        ),
                      ),
                ],
              ),
            )
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