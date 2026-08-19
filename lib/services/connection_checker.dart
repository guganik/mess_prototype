// messenger_dev/lib/dev/connection_checker.dart
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';   // <-- нужен для ChangeNotifier

class ConnectionChecker extends ChangeNotifier {
  final String pingUrl;
  Timer? _timer;
  bool isConnected = false;

  bool _checking = false;

  /// Вызывается каждый раз, когда статус соединения меняется
  Function(bool)? onChange;

  ConnectionChecker({required this.pingUrl, this.onChange});

  void start() {
    _timer?.cancel();

    _check();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _check());
  }

  Future<void> _check() async {
    if (_checking) return;

    _checking = true;

    final prev = isConnected;

    try {
      final resp = await http.get(Uri.parse(pingUrl));
      isConnected = resp.statusCode == 200;
    } catch (_) {
      isConnected = false;
    } finally {
      _checking = false;
    }

    if (prev != isConnected) {
      notifyListeners();          // <-- обновляем UI
      onChange?.call(isConnected);
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
