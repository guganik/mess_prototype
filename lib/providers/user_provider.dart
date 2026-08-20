import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/services/realtime_service.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repository;
  final RealtimeService realtimeService;

  late final StreamSubscription<Map<String, dynamic>> _realtimeSubscription;

  UserProvider({
    required this.repository,
    required this.realtimeService,
  }) {
    realtimeService.addListener(_handleRealtimeStateChanged);
    _realtimeSubscription = realtimeService.events.listen(_handleRealtimeEvent);
  }

  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isInitialized => _isInitialized;

  Future<void> loadUser() async {
    final localUser = await repository.getCurrentUser();

    if (localUser == null) {
      _user = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    final token = localUser.token;
    if (token == null || token.isEmpty) {
      await repository.deleteUser();
      _user = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    _user = localUser;
    notifyListeners();

    try {
      final serverUser = await repository.getCurrentUserFromServer();
      final syncedUser = await repository.syncAvatar(localUser, serverUser);

      _user = syncedUser;
      await repository.syncUser(syncedUser);
      notifyListeners();
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await repository.deleteUser();
        _user = null;
        notifyListeners();
      } else {
        debugPrint('Не удалось синхронизировать пользователя: $error');
      }
    } catch (error) {
      debugPrint('Не удалось синхронизировать пользователя: $error');
    }

    await realtimeService.connect(token);
    _isInitialized = true;
    notifyListeners();
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

    await realtimeService.connect(user.token ?? '');
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

    if (realtimeService.isConnected) {
      await setStatus('online');
    }
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

  void _handleRealtimeEvent(Map<String, dynamic> event) {
    final currentUser = _user;
    if (currentUser == null) return;

    final type = event['type'];
    final data = event['data'];
    if (data is! Map<String, dynamic>) return;

    if (type != 'presence.updated' && type != 'status.updated') return;
    if (data['user_id'] != currentUser.id) return;

    if (type == 'presence.updated') {
      final presence = data['presence'];
      if (presence is! String) return;

      DateTime? lastSeen;
      final rawLastSeen = data['last_seen'];
      if (rawLastSeen is String) {
        lastSeen = DateTime.tryParse(rawLastSeen);
      }

      _user = currentUser.copyWith(
        presence: presence,
        lastSeen: lastSeen,
      );
    } else {
      final status = data['status'];
      if (status is! String) return;

      _user = currentUser.copyWith(status: status);
    }

    notifyListeners();
    _persistPresence();
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

  @override
  void dispose() {
    realtimeService.removeListener(_handleRealtimeStateChanged);
    _realtimeSubscription.cancel();
    super.dispose();
  }
}
