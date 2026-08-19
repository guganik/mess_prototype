import 'package:flutter/material.dart';
import 'package:mess_prototype/screens/auth_screen.dart';

import 'package:mess_prototype/services/app_initializer.dart';

import 'package:mess_prototype/screens/main_screen.dart';
import 'package:mess_prototype/services/connection_checker.dart';
import 'package:provider/provider.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  LoadScreenState createState() => LoadScreenState();
}

class LoadScreenState extends State<LoadScreen> {
  final initializer = AppInitializer();

  @override
  void initState() {
    super.initState();
    startApp();
  }

  Future<void> startApp() async {
    final checker = context.watch<ConnectionChecker>();
    try {
      final user = await initializer.hasUser();
      final settings = await initializer.loadSettings();

      if (!mounted) return;
      
      initializer.dispose();

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              user: user,
              settings: settings,
            )
          )
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AuthScreen()
          )
        );
      }
    } catch(e) {
      print('Сервер недоступен');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}