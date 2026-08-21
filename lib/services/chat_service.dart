import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'package:mess_prototype/services/server_config.dart';

class ChatService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  
  // Данные чата
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _chats = [];
  
  // Геттеры
  bool get isConnected => _isConnected;
  List<Map<String, dynamic>> get messages => _messages;
  List<Map<String, dynamic>> get chats => _chats;

  ChatService();

  /// Подключение к WebSocket
  Future<void> connect(String userId) async {
    if (_isConnected) return;

    try {
      // Формируем URL с токеном (если есть)
      final url = '${ServerConfig.wsUrl}?user_id=$userId';
      
      _channel = IOWebSocketChannel.connect(
        url,
        headers: {
          'Origin': serverUrl,
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      notifyListeners();

      // Слушаем входящие сообщения
      _channel!.stream.listen(
        (data) {
          final message = jsonDecode(data);
          _handleIncomingMessage(message);
        },
        onError: (error) {
          _onConnectionError(error);
        },
        onDone: () {
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _onConnectionError(e);
    }
  }

  /// Отправка сообщения
  Future<void> sendMessage(String text, int recipientId) async {
    if (!_isConnected || _channel == null) return;

    final message = {
      'type': 'message',
      'text': text,
      'recipient_id': recipientId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _channel!.sink.add(jsonEncode(message));
    
    // Добавляем в локальный список (optimistic update)
    _messages.add(message);
    notifyListeners();
  }

  /// Обработка входящих сообщений
  void _handleIncomingMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'message':
        _messages.add(message);
        break;
      case 'chat_update':
        // Обновление списка чатов
        _chats = List.from(message['chats']);
        break;
      case 'error':
        print('Server error: ${message['msg']}');
        break;
    }
    notifyListeners();
  }

  /// Ошибка соединения
  void _onConnectionError(dynamic error) {
    print('Connection error: $error');
    _isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  /// Планирование переподключения (Exponential Backoff)
  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;
    
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts < 5 ? _reconnectAttempts : 10);
    
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      // Повторное подключение потребует userId, передадим его через метод
      // Для простоты, в реальном приложении userId должен храниться в состоянии
      print('Reconnecting in ${delay.inSeconds} seconds...');
    });
  }

  /// Отключение
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _reconnectTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
