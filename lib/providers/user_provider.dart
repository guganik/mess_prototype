import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

/// Единственный источник истины о текущем пользователе в UI.
///
/// Правило приложения:
/// Screen -> UserProvider -> UserRepository -> Api/Database
///
/// Screen не должен напрямую создавать ApiService/UserRepository и не должен
/// писать в локальную базу.
class UserProvider extends ChangeNotifier {
  final UserRepository repository;

  UserProvider({required this.repository});

  User? _user;
  bool _initialized = false;
  bool _busy = false;
  String? _error;
  Timer? _presenceTimer;

  User? get user => _user;
  bool get isInitialized => _initialized;
  bool get isBusy => _busy;
  String? get error => _error;

  Future<User?> initialize() async {
    if (_initialized) return _user;

    final localUser = await repository.getLocalUser();
    _user = localUser;
    _initialized = true;
    notifyListeners();

    if (localUser == null) return null;

    try {
      _user = await repository.refreshFromServer();
      _startPresence();
      notifyListeners();
      return _user;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await repository.clearLocalUser();
        _user = null;
        notifyListeners();
        return null;
      }

      // Сервер/сеть временно недоступны: локальную сессию не удаляем.
      _error = e.toString();
      notifyListeners();
      return _user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return _user;
    }
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    return _runBusy(() async {
      final user = await repository.login(
        username: username,
        password: password,
      );
      _user = user;
      _error = null;
      notifyListeners();
      _startPresence();
      return user;
    });
  }

  Future<User> register({
    required String username,
    required String password,
    String? firstName,
    String? email,
    String? phone,
  }) async {
    return _runBusy(() async {
      final user = await repository.register(
        username: username,
        password: password,
        firstName: firstName,
        email: email,
        phone: phone,
      );
      _user = user;
      _error = null;
      notifyListeners();
      _startPresence();
      return user;
    });
  }

  Future<User> refresh() async {
    return _runBusy(() async {
      final updatedUser = await repository.refreshFromServer();
      _user = updatedUser;
      _error = null;
      notifyListeners();
      return updatedUser;
    });
  }

  Future<User> updateProfile({
    String? username,
    String? firstName,
    String? email,
    String? phone,
    String? status,
  }) async {
    final currentUser = _requireUser();

    return _runBusy(() async {
      final updatedUser = await repository.updateProfile(
        currentUser: currentUser,
        username: username,
        firstName: firstName,
        email: email,
        phone: phone,
        status: status,
      );

      _user = updatedUser;
      _error = null;
      notifyListeners();
      return updatedUser;
    });
  }

  Future<User> changeStatus(String status) {
    return updateProfile(status: status);
  }

  Future<User> updatePresence() async {
    final currentUser = _user;
    if (currentUser == null || currentUser.token == null) {
      throw StateError('Пользователь не авторизован');
    }

    final updatedUser = await repository.updatePresence(currentUser);
    _user = updatedUser;
    notifyListeners();
    return updatedUser;
  }

  Future<User> setAvatar({
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final currentUser = _requireUser();

    return _runBusy(() async {
      final updatedUser = await repository.setAvatar(
        currentUser: currentUser,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      _user = updatedUser;
      _error = null;
      notifyListeners();
      return updatedUser;
    });
  }

  Future<User> removeAvatar() async {
    final currentUser = _requireUser();

    return _runBusy(() async {
      final updatedUser = await repository.removeAvatar(currentUser);
      _user = updatedUser;
      _error = null;
      notifyListeners();
      return updatedUser;
    });
  }

  Future<void> logout() async {
    _stopPresence();
    await repository.clearLocalUser();

    _user = null;
    _error = null;
    notifyListeners();
  }

  User _requireUser() {
    final currentUser = _user;
    if (currentUser == null) {
      throw StateError('Пользователь не авторизован');
    }
    return currentUser;
  }

  Future<T> _runBusy<T>(Future<T> Function() action) async {
    if (_busy) throw StateError('Операция уже выполняется');

    _busy = true;
    _error = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _startPresence() {
    _presenceTimer?.cancel();

    // Первый heartbeat отправляем сразу после авторизации.
    _sendPresenceSafely();

    _presenceTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendPresenceSafely(),
    );
  }

  void _sendPresenceSafely() {
    updatePresence().catchError((_) {
      // Presence не должна ломать основную сессию пользователя.
    });
  }

  void _stopPresence() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
  }

  @override
  void dispose() {
    _stopPresence();
    super.dispose();
  }
}
