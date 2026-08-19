import 'package:flutter/material.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:provider/provider.dart';


import 'package:mess_prototype/api/api_service.dart';

import 'package:mess_prototype/repositories/user_repository.dart';

import 'package:mess_prototype/services/chat_service.dart';
import 'package:mess_prototype/services/connection_checker.dart';
import 'package:mess_prototype/services/presence_service.dart';
import 'package:mess_prototype/services/server_config.dart';
import 'package:mess_prototype/services/user_sync_service.dart';

import 'package:mess_prototype/screens/load_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => UserSyncService()),
        ChangeNotifierProvider(create: (_) => UserProvider(repository: UserRepository())..loadUser()),
        Provider(create: (_) => PresenceService(apiService: ApiService(), userRepository: UserRepository())..start()),
        ChangeNotifierProvider(create: (_) => ConnectionChecker(pingUrl: '$serverUrl/health')..start()),
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
      home: LoadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
