import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mess_prototype/services/server_config.dart';

enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class RealtimeService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  String? _token;
  bool _shouldReconnect = false;
  int _reconnectAttempts = 0;
  RealtimeConnectionState _state = RealtimeConnectionState.disconnected;

  final StreamController<Map<String, dynamic>> _events =
      StreamController<Map<String, dynamic>>.broadcast();

  RealtimeConnectionState get state => _state;
  bool get isConnected => _state == RealtimeConnectionState.connected;
  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<bool> connect(String token) async {
    if (token.isEmpty) return false;

    _token = token;
    _shouldReconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_state == RealtimeConnectionState.connected ||
        _state == RealtimeConnectionState.connecting) {
      return isConnected;
    }

    return _connectNow();
  }

  Future<bool> _connectNow() async {
    final token = _token;
    if (!_shouldReconnect || token == null || token.isEmpty) {
      return false;
    }

    await _closeChannel();
    _setState(
      _reconnectAttempts == 0
          ? RealtimeConnectionState.connecting
          : RealtimeConnectionState.reconnecting,
    );

    try {
      final channel = IOWebSocketChannel.connect(
        Uri.parse(VlessConfig.wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Origin': serverUrl,
        },
        pingInterval: const Duration(seconds: 20),
      );

      _channel = channel;
      await channel.ready;

      if (!_shouldReconnect) {
        await channel.sink.close();
        if (identical(_channel, channel)) _channel = null;
        _setState(RealtimeConnectionState.disconnected);
        return false;
      }

      _reconnectAttempts = 0;
      _setState(RealtimeConnectionState.connected);

      _subscription = channel.stream.listen(
        _handleMessage,
        onError: _handleConnectionError,
        onDone: _handleConnectionDone,
        cancelOnError: false,
      );

      return true;
    } catch (error) {
      _handleConnectionError(error);
      return false;
    }
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final decoded = rawMessage is String
          ? jsonDecode(rawMessage)
          : jsonDecode(utf8.decode(rawMessage as List<int>));

      if (decoded is! Map<String, dynamic>) return;
      _events.add(decoded);
    } catch (error) {
      debugPrint('Realtime: invalid message: $error');
    }
  }

  bool send({required String type, Map<String, dynamic>? data}) {
    if (!isConnected || _channel == null) return false;

    _channel!.sink.add(
      jsonEncode({
        'type': type,
        'data': data ?? <String, dynamic>{},
      }),
    );
    return true;
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _token = null;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _closeChannel();
    _setState(RealtimeConnectionState.disconnected);
  }

  void _handleConnectionError(Object error) {
    debugPrint('Realtime connection error: $error');
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _setState(RealtimeConnectionState.disconnected);

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _handleConnectionDone() {
    _subscription = null;
    _channel = null;
    _setState(RealtimeConnectionState.disconnected);

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectTimer != null) return;

    _reconnectAttempts++;
    final seconds = _reconnectAttempts.clamp(1, 10);

    _reconnectTimer = Timer(Duration(seconds: seconds), () async {
      _reconnectTimer = null;
      await _connectNow();
    });
  }

  Future<void> _closeChannel() async {
    await _subscription?.cancel();
    _subscription = null;

    final channel = _channel;
    _channel = null;

    if (channel != null) {
      try {
        await channel.sink.close();
      } catch (_) {}
    }
  }

  void _setState(RealtimeConnectionState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _events.close();
    super.dispose();
  }
}
