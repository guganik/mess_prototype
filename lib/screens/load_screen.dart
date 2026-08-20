import 'package:flutter/material.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/screens/auth_screen.dart';
import 'package:mess_prototype/screens/main_screen.dart';
import 'package:mess_prototype/services/connection_checker.dart';
import 'package:provider/provider.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    final checker = context.read<ConnectionChecker>();

    while (!checker.isConnected && mounted) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    try {
      final userProvider = context.read<UserProvider>();
      final user = await userProvider.initialize();
      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка запуска приложения: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              strokeWidth: 6,
            ),
            SizedBox(height: 48),
            Text(
              'Подключение...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Проверь подключение к интернету или отключи VPN\n'
              '(либо Русский сервер поставь)',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
