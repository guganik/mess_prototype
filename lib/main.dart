import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/database/database_provider.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/services/avatar_cache.dart';
import 'package:mess_prototype/services/chat_service.dart';
import 'package:mess_prototype/services/connection_checker.dart';
import 'package:mess_prototype/services/server_config.dart';
import 'package:mess_prototype/screens/load_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // Единственный экземпляр HTTP-клиента на всё приложение.
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, api) => api.dispose(),
        ),

        // Единственный repository пользователя на всё приложение.
        Provider<UserRepository>(
          create: (context) => UserRepository(
            apiService: context.read<ApiService>(),
            avatarCache: AvatarCache(),
            database: database,
          ),
        ),

        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            repository: context.read<UserRepository>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => ChatService()),
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
