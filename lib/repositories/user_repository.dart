import 'package:drift/drift.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/database/database_provider.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/services/avatar_cache.dart';

/// Единственная точка работы с данными пользователя.
///
/// Repository решает ОТКУДА взять/куда сохранить данные:
/// - HTTP через ApiService;
/// - локально через Drift;
/// - локальный кэш аватара через AvatarCache.
///
/// UI и Provider не должны обращаться к этим источникам напрямую.
class UserRepository {
  final ApiService apiService;
  final AvatarCache avatarCache;
  final AppDatabase database;

  UserRepository({
    required this.apiService,
    required this.avatarCache,
    required this.database,
  });

  Future<User?> getLocalUser() async {
    final data = await database.getUser();
    if (data == null) return null;
    return _fromLocal(data);
  }

  Future<void> saveLocalUser(User user) async {
    await database.deleteUser();

    await database.saveUser(
      LocalUsersCompanion.insert(
        id: user.id,
        username: user.username,
        firstName: Value(user.firstName),
        email: Value(user.email),
        phone: Value(user.phone),
        avatarFileId: Value(user.avatarFileId),
        avatarLocalPath: Value(user.avatarLocalPath),
        status: Value(user.status),
        presence: Value(user.presence),
        lastSeen: Value(user.lastSeen),
        isActive: Value(user.isActive),
        token: Value(user.token),
      ),
    );
  }

  Future<void> updateLocalUser(User user) async {
    final localUser = await getLocalUser();

    if (localUser == null) {
      await saveLocalUser(user);
      return;
    }

    await database.updateUser(
      user.id,
      username: user.username,
      firstName: user.firstName,
      email: user.email,
      phone: user.phone,
      avatarFileId: Value(user.avatarFileId),
      avatarLocalPath: Value(user.avatarLocalPath),
      status: user.status,
      presence: user.presence,
      lastSeen: user.lastSeen,
      isActive: user.isActive,
      token: user.token,
    );
  }

  Future<void> clearLocalUser() => database.deleteUser();

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final auth = await apiService.login(
      username: username,
      password: password,
    );

    final serverUser = await apiService.getCurrentUser(
      token: auth.accessToken,
    );

    final user = serverUser.copyWith(token: auth.accessToken);
    final userWithAvatar = await _syncAvatar(null, user);

    await saveLocalUser(userWithAvatar);
    return userWithAvatar;
  }

  Future<User> register({
    required String username,
    required String password,
    String? firstName,
    String? email,
    String? phone,
  }) async {
    await apiService.register(
      username: username,
      password: password,
      firstName: firstName,
      email: email,
      phone: phone,
    );

    // Сервер регистрации не возвращает токен, поэтому после регистрации
    // авторизуемся обычным способом и сохраняем единственную актуальную сессию.
    return login(
      username: username,
      password: password,
    );
  }

  Future<User> refreshFromServer() async {
    final localUser = await getLocalUser();

    if (localUser == null) {
      throw StateError('Пользователь не найден локально');
    }

    final token = localUser.token;
    if (token == null || token.isEmpty) {
      throw StateError('Токен авторизации отсутствует');
    }

    final serverUser = await apiService.getCurrentUser(token: token);
    final updatedUser = await _syncAvatar(localUser, serverUser.copyWith(token: token));

    await updateLocalUser(updatedUser);
    return updatedUser;
  }

  Future<User> updateProfile({
    required User currentUser,
    String? username,
    String? firstName,
    String? email,
    String? phone,
    String? status,
  }) async {
    final token = _requireToken(currentUser);

    final serverUser = await apiService.updateCurrentUser(
      token: token,
      username: username,
      firstName: firstName,
      email: email,
      phone: phone,
      status: status,
    );

    final updatedUser = serverUser.copyWith(
      token: token,
      avatarLocalPath: currentUser.avatarLocalPath,
    );

    await updateLocalUser(updatedUser);
    return updatedUser;
  }

  Future<User> updatePresence(User currentUser) async {
    final token = _requireToken(currentUser);

    final serverUser = await apiService.updatePresence(token: token);
    final updatedUser = serverUser.copyWith(
      token: token,
      avatarLocalPath: currentUser.avatarLocalPath,
    );

    await updateLocalUser(updatedUser);
    return updatedUser;
  }

  Future<User> setAvatar({
    required User currentUser,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final token = _requireToken(currentUser);

    final fileId = await apiService.uploadAvatar(
      token: token,
      imageBytes: imageBytes,
      fileName: fileName,
    );

    final serverUser = await apiService.updateAvatar(
      token: token,
      fileId: fileId,
    );

    final localPath = await avatarCache.downloadAvatar(
      fileId: fileId,
      token: token,
    );

    if (currentUser.avatarFileId != null && currentUser.avatarFileId != fileId) {
      final oldPath = await avatarCache.getAvatarPath(currentUser.avatarFileId!);
      await avatarCache.deleteAvatar(oldPath);
    }

    final updatedUser = serverUser.copyWith(
      token: token,
      avatarLocalPath: localPath,
    );

    await updateLocalUser(updatedUser);
    return updatedUser;
  }

  Future<User> removeAvatar(User currentUser) async {
    final token = _requireToken(currentUser);
    final oldAvatarId = currentUser.avatarFileId;

    final serverUser = await apiService.deleteAvatar(token: token);

    if (oldAvatarId != null) {
      final oldPath = await avatarCache.getAvatarPath(oldAvatarId);
      await avatarCache.deleteAvatar(oldPath);
    }

    final updatedUser = serverUser.copyWith(
      token: token,
      avatarFileId: null,
      avatarLocalPath: null,
    );

    await updateLocalUser(updatedUser);
    return updatedUser;
  }

  User _fromLocal(LocalUser data) {
    return User(
      id: data.id,
      username: data.username,
      firstName: data.firstName,
      email: data.email,
      phone: data.phone,
      avatarFileId: data.avatarFileId,
      avatarLocalPath: data.avatarLocalPath,
      status: data.status,
      presence: data.presence,
      lastSeen: data.lastSeen,
      isActive: data.isActive,
      token: data.token,
    );
  }

  Future<User> _syncAvatar(User? localUser, User serverUser) async {
    final serverAvatarId = serverUser.avatarFileId;
    final localAvatarId = localUser?.avatarFileId;

    if (serverAvatarId == null) {
      if (localAvatarId != null) {
        final oldPath = await avatarCache.getAvatarPath(localAvatarId);
        await avatarCache.deleteAvatar(oldPath);
      }

      return serverUser.copyWith(
        avatarFileId: null,
        avatarLocalPath: null,
      );
    }

    final cachedPath = await avatarCache.getAvatarPath(serverAvatarId);
    if (cachedPath != null) {
      if (localAvatarId != null && localAvatarId != serverAvatarId) {
        final oldPath = await avatarCache.getAvatarPath(localAvatarId);
        await avatarCache.deleteAvatar(oldPath);
      }

      return serverUser.copyWith(avatarLocalPath: cachedPath);
    }

    final token = _requireToken(serverUser);
    final newPath = await avatarCache.downloadAvatar(
      fileId: serverAvatarId,
      token: token,
    );

    if (newPath == null) {
      return serverUser.copyWith(
        avatarLocalPath: localUser?.avatarLocalPath,
      );
    }

    if (localAvatarId != null && localAvatarId != serverAvatarId) {
      final oldPath = await avatarCache.getAvatarPath(localAvatarId);
      await avatarCache.deleteAvatar(oldPath);
    }

    return serverUser.copyWith(avatarLocalPath: newPath);
  }

  String _requireToken(User user) {
    final token = user.token;
    if (token == null || token.isEmpty) {
      throw StateError('Токен авторизации отсутствует');
    }
    return token;
  }
}
