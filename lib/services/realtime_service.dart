import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mess_prototype/services/server_config.dart';

enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class RealtimeService extends ChangeNotifier with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  String? _token;
  String? _deviceId;

  bool _shouldReconnect = false;
  bool _connecting = false;

  int _reconnectAttempts = 0;

  RealtimeConnectionState _state =
      RealtimeConnectionState.disconnected;

  final StreamController<Map<String, dynamic>> _events =
      StreamController<Map<String, dynamic>>.broadcast();

  RealtimeConnectionState get state => _state;

  bool get isConnected =>
      _state == RealtimeConnectionState.connected;

  Stream<Map<String, dynamic>> get events => _events.stream;

  String? get deviceId => _deviceId;

  RealtimeService() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resumeFromBackground();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pauseForBackground();
        break;

      default:
        break;
    }
  }

  void _pauseForBackground() {
    if (!_shouldReconnect &&
        _channel == null) {
      return;
    }

    _shouldReconnect = false;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    unawaited(_closeChannel());

    _setState(
      RealtimeConnectionState.disconnected,
    );
  }

  void _resumeFromBackground() {
    if (_token == null ||
        _token!.isEmpty ||
        _deviceId == null ||
        _deviceId!.isEmpty) {
      return;
    }

    _shouldReconnect = true;

    unawaited(
      _connectNow(),
    );
  }

  Future<bool> connect({
    required String token,
    required String deviceId,
  }) async {
    if (token.isEmpty || deviceId.isEmpty) {
      return false;
    }

    _token = token;
    _deviceId = deviceId;
    _shouldReconnect = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_state == RealtimeConnectionState.connected) {
      return true;
    }

    if (_connecting) {
      return false;
    }

    return _connectNow();
  }

  Future<bool> _connectNow() async {
    if (_connecting) {
      return false;
    }

    final token = _token;
    final deviceId = _deviceId;

    if (!_shouldReconnect ||
        token == null ||
        token.isEmpty ||
        deviceId == null ||
        deviceId.isEmpty) {
      return false;
    }

    _connecting = true;

    final uri = Uri.parse(
      ServerConfig.wsUrl,
    ).replace(
      queryParameters: {
        'device_id': deviceId,
      },
    );

    _setState(
      _reconnectAttempts == 0
          ? RealtimeConnectionState.connecting
          : RealtimeConnectionState.reconnecting,
    );

    try {
      await _closeChannel();

      final channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Origin': ServerConfig.apiBaseUrl,
        },
        pingInterval: const Duration(seconds: 20),
      );

      _channel = channel;

      await channel.ready;

      if (!_shouldReconnect ||
          !identical(_channel, channel)) {
        await channel.sink.close();

        if (identical(_channel, channel)) {
          _channel = null;
        }

        _setState(
          RealtimeConnectionState.disconnected,
        );

        return false;
      }

      _reconnectAttempts = 0;

      _subscription = channel.stream.listen(
        _handleMessage,
        onError: (Object error, StackTrace stackTrace) {
          _handleConnectionError(channel, error);
        },
        onDone: () {
          _handleConnectionDone(channel);
        },
        cancelOnError: false,
      );

      _setState(
        RealtimeConnectionState.connected,
      );

      return true;
    } catch (error) {
      debugPrint(
        'Realtime connection error: $error',
      );

      if (_shouldReconnect) {
        _scheduleReconnect();
      }

      _setState(
        RealtimeConnectionState.disconnected,
      );

      return false;
    } finally {
      _connecting = false;
    }
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final dynamic decoded;

      if (rawMessage is String) {
        decoded = jsonDecode(rawMessage);
      } else if (rawMessage is List<int>) {
        decoded = jsonDecode(
          utf8.decode(rawMessage),
        );
      } else {
        return;
      }

      if (decoded is! Map<String, dynamic>) {
        return;
      }

      _events.add(decoded);
    } catch (error) {
      debugPrint(
        'Realtime invalid message: $error',
      );
    }
  }

  bool send({
    required String type,
    Map<String, dynamic>? data,
  }) {
    final channel = _channel;

    if (!isConnected || channel == null) {
      return false;
    }

    try {
      channel.sink.add(
        jsonEncode({
          'type': type,
          'data': data ?? <String, dynamic>{},
        }),
      );

      return true;
    } catch (error) {
      debugPrint(
        'Realtime send error: $error',
      );

      return false;
    }
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _token = null;
    _deviceId = null;
    _reconnectAttempts = 0;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _closeChannel();

    _setState(
      RealtimeConnectionState.disconnected,
    );
  }

  void _handleConnectionError(
    WebSocketChannel channel,
    Object error,
  ) {
    debugPrint(
      'Realtime socket error: $error',
    );

    if (!identical(_channel, channel)) {
      return;
    }

    _subscription = null;
    _channel = null;

    _setState(
      RealtimeConnectionState.disconnected,
    );

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _handleConnectionDone(
    WebSocketChannel channel,
  ) {
    if (!identical(_channel, channel)) {
      return;
    }

    _subscription = null;
    _channel = null;

    _setState(
      RealtimeConnectionState.disconnected,
    );

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect ||
        _reconnectTimer != null ||
        _connecting) {
      return;
    }

    _reconnectAttempts++;

    final seconds =
        _reconnectAttempts.clamp(1, 10);

    _reconnectTimer = Timer(
      Duration(seconds: seconds),
      () {
        _reconnectTimer = null;

        if (!_shouldReconnect) {
          return;
        }

        unawaited(
          _connectNow(),
        );
      },
    );
  }

  Future<void> _closeChannel() async {
    final subscription = _subscription;
    _subscription = null;

    if (subscription != null) {
      try {
        await subscription.cancel();
      } catch (_) {}
    }

    final channel = _channel;
    _channel = null;

    if (channel != null) {
      try {
        await channel.sink.close();
      } catch (_) {}
    }
  }

  void _setState(
    RealtimeConnectionState value,
  ) {
    if (_state == value) {
      return;
    }

    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    _shouldReconnect = false;

    _reconnectTimer?.cancel();

    _subscription?.cancel();
    _channel?.sink.close();

    _events.close();

    super.dispose();
  }
}