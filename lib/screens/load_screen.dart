import 'package:flutter/material.dart';
import 'package:mess_prototype/services/device_info_service.dart';
import 'package:provider/provider.dart';

import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/app_settings_repository.dart';
import 'package:mess_prototype/screens/auth_screen.dart';
import 'package:mess_prototype/screens/register_screen.dart';
import 'package:mess_prototype/screens/main_screen.dart';
import 'package:mess_prototype/services/connection_checker.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  final SettingsRepository settingsRepository = SettingsRepository();

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    final deviceInfo = await context
      .read<DeviceInfoService>()
      .getDeviceInfo();

    debugPrint('DEVICE ID: ${deviceInfo.deviceId}');
    debugPrint('DEVICE NAME: ${deviceInfo.deviceName}');
    debugPrint('PLATFORM: ${deviceInfo.platform}');

    if (!mounted) return;
    
    final checker = context.read<ConnectionChecker>();

    while (!checker.isConnected) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
    }

    final userProvider = context.read<UserProvider>();

    await userProvider.loadUser();

    final settings = await settingsRepository.getAppSettings();
    final user = userProvider.user;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null
          ? MainScreen(settings: settings)
          : const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeAlign: 6,
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
              'Проверь подключение к интернету или отключи VPN\n(либо Русский сервер поставь)',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
