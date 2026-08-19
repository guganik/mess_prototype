import 'package:drift/drift.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/database/database_provider.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/services/avatar_cache.dart';

class UserRepository {
  final ApiService apiService = ApiService();
  final AvatarCache avatarCache = AvatarCache();

  Future<User?> getCurrentUser() async {
    final data = await database.getUser();

    if (data == null) {
      return null;
    }

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
      token: data.token
    );
  }

  Future<User> getCurrentUserFromServer() async {
    final localUser = await getCurrentUser();

    if (localUser == null) throw Exception('Пользователь не найден');

    final token = localUser.token;

    if (token == null || token.isEmpty) throw Exception('Токен авторизации отсутствует');

    final serverUser = await apiService.getCurrentUser(token: token);

    return serverUser.copyWith(token: localUser.token);
  }

  Future<void> saveUser(User user) async {
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
      )
    );
  }

  Future<void> syncUser(User user) async {
    final existingUser = await getCurrentUser();

    if (existingUser == null) {
      await saveUser(user);
      return;
    }

    await updateUser(user);
  }

  Future<void> updateUser(User user) async {
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

  Future<String> uploadAvatar({
    required List<int> imageBytes,
    required String fileName
  }) async {
    final user = await getCurrentUser();

    if (user == null) throw Exception('Пользователь не найден');

    final token = user.token;

    if (token == null || token.isEmpty) throw Exception('Токен авторизации отсутствует');

    return await apiService.uploadAvatar(
      token: token,
      imageBytes: imageBytes,
      fileName: fileName
    ); 
  }

  Future<User> updateAvatar({
    required String fileId
  }) async {
    final user = await getCurrentUser();

    if (user == null) throw Exception('Пользователь не найден');

    final token = user.token;

    if (token == null || token.isEmpty) throw Exception('Токен авторизации отсутствует');

    return await apiService.updateAvatar(
      token: token,
      fileId: fileId
    );
  }

  Future<User> syncAvatar(User localUser, User serverUser) async {
    final localAvatarId = localUser.avatarFileId;
    final serverAvatarId = serverUser.avatarFileId;

    if (serverAvatarId == null) {
      if (localAvatarId != null) {
        final localPath = await avatarCache.getAvatarPath(localAvatarId);

        await avatarCache.deleteAvatar(localPath);
      }

      return User(
        id: serverUser.id,
        username: serverUser.username,
        firstName: serverUser.firstName,
        email: serverUser.email,
        phone: serverUser.phone,
        avatarFileId: null,
        avatarLocalPath: null,
        status: serverUser.status,
        presence: serverUser.presence,
        lastSeen: serverUser.lastSeen,
        isActive: serverUser.isActive,
        token: serverUser.token,
      );
    }

    final localPath = await avatarCache.getAvatarPath(serverAvatarId);

    if (localPath != null) {
      return serverUser.copyWith(token: localUser.token, avatarLocalPath: localPath);
    }

    final newPath = await avatarCache.downloadAvatar(fileId: serverAvatarId, token: localUser.token!);

    if (newPath == null) {
      return localUser;
    }

    if (localAvatarId != null && localAvatarId != serverAvatarId) {
      final oldPath = await avatarCache.getAvatarPath(localAvatarId);

      await avatarCache.deleteAvatar(oldPath);
    }

    return serverUser.copyWith(token: localUser.token, avatarLocalPath: newPath);
  }

  Future<User> deleteAvatar() async {
    final user = await getCurrentUser();

    if (user == null) throw Exception('Пользователь не найден');

    final token = user.token;

    if (token == null || token.isEmpty) throw Exception('Токен авторизации отсутствует');

    return await apiService.deleteAvatar(token: token);
  }

  Future<void> deleteUser() {
    return database.deleteUser();
  }
}