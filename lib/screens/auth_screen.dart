import 'package:flutter/material.dart';
import 'package:mess_prototype/api/api_service.dart';

import 'package:mess_prototype/controllers/auth_controller.dart';
import 'package:mess_prototype/repositories/app_settings_repository.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/screens/register_screen.dart';

import 'package:mess_prototype/screens/main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final controller = AuthController();
  final apiService = ApiService();

  bool loading = false;
  
  bool hovered = false;

  String? errorText;

  Future<void> authorization() async {
    setState(() {
      loading = true;
    });

    try {
      final authResponse = await apiService.login(
        username: controller.username,
        password: controller.password
      );

      final serverUser = await apiService.getCurrentUser(token: authResponse.accessToken);
      final user = serverUser.copyWith(token: authResponse.accessToken);

      final userRepository = UserRepository();
      await userRepository.saveUser(user);
      
      final settingsRepository = SettingsRepository();
      final settings = await settingsRepository.getAppSettings();
      
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            user: user,
            settings: settings,
          )
        )
      );
    }

    catch(e) {
      setState(() {
        errorText = 'Пользователь не найден';
      });
    }

    finally {
      setState(() {
        loading = false;
      });
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
                      hintText: 'Имя пользователя'
                    ),
                  ),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Пароль'
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