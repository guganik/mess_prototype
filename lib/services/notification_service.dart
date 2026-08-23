import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Windows
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Googa',
      appUserModelId: 'googa-talk',
      guid: '6f7f6e2c-7f9a-4f3d-9d2d-2f3a5c7b9e11',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(
      settings: settings,
    );
  }

  static Future<void> showMessage({
    required String senderName,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'messages',
      'Сообщения',
      channelDescription: 'Уведомления о новых сообщениях',
      importance: Importance.high,
      priority: Priority.high,
    );

    const windowsDetails = WindowsNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      windows: windowsDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: senderName,
      body: message,
      notificationDetails: details,
    );
  }
}