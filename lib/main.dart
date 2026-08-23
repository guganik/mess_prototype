import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/firebase_options.dart';
import 'package:mess_prototype/providers/chat_provider.dart';
import 'package:mess_prototype/providers/friend_provider.dart';
import 'package:mess_prototype/repositories/chat_repository.dart';
import 'package:mess_prototype/repositories/device_repository.dart';
import 'package:mess_prototype/repositories/friend_repository.dart';
import 'package:mess_prototype/repositories/message_repository.dart';
import 'package:mess_prototype/services/device_info_service.dart';
import 'package:mess_prototype/services/notification_service.dart';
import 'package:provider/provider.dart';

import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/services/connection_checker.dart';
import 'package:mess_prototype/services/realtime_service.dart';
import 'package:mess_prototype/services/server_config.dart';
import 'package:mess_prototype/screens/load_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final apiService = ApiService();
  final realtimeService = RealtimeService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>(create: (_) => AppDatabase()),

        Provider<ApiService>.value(value: apiService),

        Provider<DeviceInfoService>(create: (_) => DeviceInfoService()),

        ChangeNotifierProvider<RealtimeService>.value(value: realtimeService),

        Provider<MessageRepository>(
          create: (context) => MessageRepository(
            database: context.read<AppDatabase>(),
          ),
        ),

        Provider<UserRepository>(
          create: (context) => UserRepository(
            apiService: context.read<ApiService>(),
            deviceInfoService:
              context.read<DeviceInfoService>(),
          ),
        ),

        Provider<ChatRepository>(
          create: (context) => ChatRepository(
            apiService: context.read<ApiService>(),
            userRepository:
                context.read<UserRepository>(),
            messageRepository:
                context.read<MessageRepository>(),
            database: context.read<AppDatabase>(),
          ),
        ),

        Provider<DeviceRepository>(create: (_) => DeviceRepository(apiService: apiService),),
        
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            repository: context.read<UserRepository>(),
            realtimeService: context.read<RealtimeService>(),
            deviceRepository: context.read<DeviceRepository>(),
            deviceInfoService: context.read<DeviceInfoService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ConnectionChecker(
            pingUrl: '$serverUrl/health', 
          )..start(),
        ),

        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            repository:
                context.read<ChatRepository>(),
            messageRepository:
                context.read<MessageRepository>(),
            userRepository:
                context.read<UserRepository>(),
            realtimeService:
                context.read<RealtimeService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => FriendProvider(
            repository: FriendRepository(
              apiService: context.read<ApiService>(),
            ),
            userRepository:
                context.read<UserRepository>(),
            realtimeService:
                context.read<RealtimeService>(),
          ),
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
