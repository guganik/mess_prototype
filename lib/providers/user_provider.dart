import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/repositories/device_repository.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/services/device_info_service.dart';
import 'package:mess_prototype/services/realtime_service.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repository;
  final RealtimeService realtimeService;
  final DeviceRepository deviceRepository;
  final DeviceInfoService deviceInfoService;

  late final StreamSubscription<Map<String, dynamic>> _realtimeSubscription;

  UserProvider({
    required this.repository,
    required this.realtimeService,
    required this.deviceRepository,
    required this.deviceInfoService,
  }) {
    realtimeService.addListener(_handleRealtimeStateChanged);
    _realtimeSubscription = realtimeService.events.listen(_handleRealtimeEvent);
  }

  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isInitialized => _isInitialized;

  Future<void> loadUser() async {
    try {
      final localUser = await repository.getCurrentUser();

      if (localUser == null) {
        _user = null;
        return;
      }

      final token = localUser.token;

      if (token == null || token.isEmpty) {
        await repository.deleteUser();
        _user = null;
        return;
      }

      _user = localUser;
      notifyListeners();

      try {
        final syncedUser = await repository.synchronizeAccount();

        try {
          await _chatProvider?.sync();
        } catch (error) {
          debugPrint(
            'Chat sync failed: $error',
          );
        }

        _user = syncedUser;
        notifyListeners();
      } on ApiException catch (error) {
        if (error.statusCode == 401 ||
            error.statusCode == 403) {
          await repository.deleteUser();
          _user = null;
          notifyListeners();

          return;
        }

        debugPrint(
          'Не удалось синхронизировать пользователя: $error',
        );
      } catch (error) {
        debugPrint(
          'Не удалось синхронизировать пользователя: $error',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'Ошибка загрузки пользователя: $error',
      );
      debugPrint(
        stackTrace.toString(),
      );
    } finally {
      // Приложение считается инициализированным,
      // даже если realtime сейчас недоступен.
      _isInitialized = true;
      notifyListeners();
    }

    // Realtime подключаем ПОСЛЕ завершения инициализации.
    // Ошибка WS не должна блокировать запуск приложения.
    final currentUser = _user;
    final token = currentUser?.token;

    if (currentUser != null &&
        token != null &&
        token.isNotEmpty) {
      unawaited(
        _connectCurrentDevice(token),
      );
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final user = await repository.authenticate(
      username: username,
      password: password,
    );

    await repository.saveUser(user);

    _user = user;
    notifyListeners();

    final syncedUser =
        await repository.synchronizeAccount();

    _user = syncedUser;
    notifyListeners();

    await _connectCurrentDevice(
      syncedUser.token ?? '',
    );
  }

  Future<void> register({
    required String username,
    required String password,
    String? firstName,
    String? email,
    String? phone,
  }) async {
    await repository.register(
      username: username,
      password: password,
      firstName: firstName,
      email: email,
      phone: phone,
    );

    await login(
      username: username,
      password: password,
    );
  }

  Future<void> updateUser(User user) async {
    final currentUser = _user;

    if (currentUser != null &&
        user.avatarFileId == currentUser.avatarFileId &&
        user.avatarLocalPath == null) {
      user = user.copyWith(
        avatarLocalPath: currentUser.avatarLocalPath,
        token: currentUser.token,
      );
    }

    _user = user;
    await repository.syncUser(user);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? username,
    String? firstName,
    String? email,
    String? phone,
    String? status,
  }) async {
    final updatedUser = await repository.updateProfile(
      username: username,
      firstName: firstName,
      email: email,
      phone: phone,
      status: status,
    );

    await updateUser(updatedUser);
  }

  Future<void> setStatus(String status) async {
    final currentUser = _user;
    if (currentUser == null || !realtimeService.isConnected) return;

    final sent = realtimeService.send(
      type: 'status.set',
      data: {'status': status},
    );

    if (!sent) return;

    _user = currentUser.copyWith(status: status);
    await repository.updateUser(_user!);
    notifyListeners();
  }

  Future<void> setAvatar({
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final currentUser = _user;
    if (currentUser == null) throw Exception('Пользователь не найден');

    final fileId = await repository.uploadAvatar(
      imageBytes: imageBytes,
      fileName: fileName,
    );

    final updatedUser = await repository.updateAvatar(fileId: fileId);

    final token = currentUser.token;
    if (token == null || token.isEmpty) {
      throw Exception('Токен авторизации отсутствует');
    }

    final localPath = await repository.avatarCache.downloadAvatar(
      fileId: fileId,
      token: token,
    );

    if (currentUser.avatarFileId != null) {
      final oldPath = await repository.avatarCache.getAvatarPath(
        currentUser.avatarFileId!,
      );
      await repository.avatarCache.deleteAvatar(oldPath);
    }

    final userWithLocalAvatar = updatedUser.copyWith(
      token: token,
      avatarLocalPath: localPath,
    );

    _user = userWithLocalAvatar;
    await repository.saveUser(userWithLocalAvatar);
    notifyListeners();
  }

  Future<void> removeAvatar() async {
    final currentUser = _user;
    if (currentUser == null) throw Exception('Пользователь не найден');

    final oldAvatarId = currentUser.avatarFileId;
    final updatedUser = await repository.deleteAvatar();

    if (oldAvatarId != null) {
      final oldPath = await repository.avatarCache.getAvatarPath(oldAvatarId);
      await repository.avatarCache.deleteAvatar(oldPath);
    }

    final userWithoutAvatar = User(
      id: updatedUser.id,
      username: updatedUser.username,
      firstName: updatedUser.firstName,
      email: updatedUser.email,
      phone: updatedUser.phone,
      avatarFileId: null,
      avatarLocalPath: null,
      status: updatedUser.status,
      presence: updatedUser.presence,
      lastSeen: updatedUser.lastSeen,
      isActive: updatedUser.isActive,
      token: currentUser.token,
    );

    _user = userWithoutAvatar;
    await repository.syncUser(userWithoutAvatar);
    notifyListeners();
  }

  Future<void> logout() async {
    await realtimeService.disconnect();
    await repository.deleteUser();

    _user = null;
    notifyListeners();
  }

  void _handleRealtimeStateChanged() {
    final currentUser = _user;
    if (currentUser == null) return;

    if (realtimeService.isConnected && currentUser.presence == 'offline') {
      // The server will send the authoritative presence.updated event.
      return;
    }

    if (!realtimeService.isConnected && currentUser.presence == 'online') {
      _user = currentUser.copyWith(
        presence: 'offline',
        lastSeen: DateTime.now(),
      );
      notifyListeners();
      _persistPresence();
    }
  }

  Future<void> _handleRealtimeEvent(
    Map<String, dynamic> event,
  ) async {
    final currentUser = _user;

    if (currentUser == null) {
      return;
    }

    final type = event['type'];
    final data = event['data'];

    if (type is! String ||
        data is! Map<String, dynamic>) {
      return;
    }

    final userId = data['user_id'];

    if (userId != currentUser.id) {
      return;
    }
    print(type);

    switch (type) {
      case 'presence.updated':
        final presence = data['presence'];

        if (presence is! String) {
          return;
        }

        DateTime? lastSeen;

        final rawLastSeen = data['last_seen'];

        if (rawLastSeen is String) {
          lastSeen = DateTime.tryParse(rawLastSeen);
        }

        _user = currentUser.copyWith(
          presence: presence,
          lastSeen: lastSeen,
        );

        await _persistPresence();
        notifyListeners();
        return;

      case 'status.updated':
        final status = data['status'];

        if (status is! String) {
          return;
        }

        _user = currentUser.copyWith(
          status: status,
        );

        await _persistPresence();
        notifyListeners();
        return;

      case 'profile.updated':
        DateTime? lastSeen;

        final rawLastSeen = data['last_seen'];

        if (rawLastSeen is String) {
          lastSeen = DateTime.tryParse(rawLastSeen);
        }

        final updatedUser = currentUser.copyWith(
          username: data['username'] as String?,
          firstName: data['first_name'] as String?,
          email: data['email'] as String?,
          phone: data['phone'] as String?,
          status: data['status'] as String?,
          presence: data['presence'] as String?,
          lastSeen: lastSeen,
          isActive: data['is_active'] as bool?,
        );

        _user = updatedUser;

        await repository.updateUser(
          updatedUser,
        );

        notifyListeners();
        return;

      case 'avatar.updated':
        final avatarFileId =
            data['avatar_file_id'] as String?;

        final updatedUser =
            await repository.applyRemoteAvatar(
          avatarFileId,
        );

        _user = updatedUser;

        notifyListeners();
        return;

      default:
        debugPrint(
          'Неизвестное realtime-событие: $type',
        );
        return;
    }
  }

  Future<void> _persistPresence() async {
    final currentUser = _user;
    if (currentUser == null) return;

    try {
      await repository.updateUser(currentUser);
    } catch (error) {
      debugPrint('Не удалось сохранить presence локально: $error');
    }
  }

  Future<void> _connectCurrentDevice(
    String token,
  ) async {
    if (token.isEmpty) {
      return;
    }

    try {
      final deviceInfo =
          await deviceInfoService.getDeviceInfo();

      final deviceSession =
          await deviceRepository.registerCurrentDevice(
        token: token,
        deviceInfo: deviceInfo,
      );

      debugPrint(
        'Device session: ${deviceSession.sessionId}',
      );

      final connected =
          await realtimeService.connect(
        token: token,
        deviceId: deviceInfo.deviceId,
      );

      debugPrint(
        'Realtime connected: $connected',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Не удалось подключить устройство: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );
    }
  }

  @override
  void dispose() {
    realtimeService.removeListener(_handleRealtimeStateChanged);
    _realtimeSubscription.cancel();
    super.dispose();
  }
}
