import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  debugPrint(
    'FCM background message: ${message.messageId}',
  );
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static bool _initialized = false;

  static Future<void> initialize({
    required ApiService apiService,
    required String authToken,
    required String deviceId,
  }) async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    final token = await _messaging.getToken();

    if (token != null && token.isNotEmpty) {
      debugPrint('FCM TOKEN: $token');

      await apiService.updateFcmToken(
        token: authToken,
        deviceId: deviceId,
        fcmToken: token,
      );
    }

    debugPrint('FCM token успешно отправлен на сервер');

    _messaging.onTokenRefresh.listen(
      (newToken) async {
        if (newToken.isEmpty) {
          return;
        }

        try {
          await apiService.updateFcmToken(
            token: authToken,
            deviceId: deviceId,
            fcmToken: newToken,
          );
        } catch (error) {
          debugPrint(
            'FCM token update error: $error',
          );
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        final notification = message.notification;

        if (notification == null) {
          return;
        }

        await NotificationService.showMessage(
          senderName:
              notification.title ?? 'Новое сообщение',
          message:
              notification.body ?? '',
        );
      },
    );
  }
}