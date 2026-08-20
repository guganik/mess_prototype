import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/services/connection_checker.dart';
import 'package:mess_prototype/services/realtime_service.dart';
import 'package:mess_prototype/services/server_config.dart';
import 'package:mess_prototype/screens/load_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final apiService = ApiService();
  final userRepository = UserRepository(apiService: apiService);
  final realtimeService = RealtimeService();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<UserRepository>.value(value: userRepository),
        ChangeNotifierProvider<RealtimeService>.value(value: realtimeService),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            repository: userRepository,
            realtimeService: realtimeService,
          )..loadUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectionChecker(
            pingUrl: '$serverUrl/health',
          )..start(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
