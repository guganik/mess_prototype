import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  debugPrint(
    'FCM background message: ${message.messageId}',
  );
}

class PushNotificationService {
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    final token = await messaging.getToken();

    debugPrint('FCM TOKEN: $token');

    messaging.onTokenRefresh.listen(
      (newToken) {
        debugPrint('NEW FCM TOKEN: $newToken');
      },
    );
  }
}