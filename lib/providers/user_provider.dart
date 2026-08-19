import 'package:flutter/foundation.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repository;

  UserProvider({
    required this.repository,
  });

  User? _user;
  User? get user => _user;

  Future<void> loadUser() async {
    final localUser = await repository.getCurrentUser();

    _user = localUser;

    notifyListeners();

    if (localUser == null) return;

    try {
      final serverUser = await repository.getCurrentUserFromServer();

      final syncedUser = await repository.syncAvatar(localUser, serverUser);

      _user = syncedUser;

      await repository.syncUser(syncedUser);

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Не удалось синхронизировать пользователя: $e'
      );
    }
  }

  Future<void> updateUser(User user) async {
    final currentUser = _user;

    if (currentUser != null && user.avatarFileId == currentUser.avatarFileId && user.avatarLocalPath == null) {
      user = user.copyWith(avatarLocalPath: currentUser.avatarLocalPath, token: currentUser.token);
    }

    _user = user;
    
    await repository.syncUser(user);

    notifyListeners();
  }

  Future<void> setAvatar({
    required List<int> imageBytes,
    required String fileName
  }) async {
    final currentUser = _user;

    if (currentUser == null) throw Exception('Пользователь не найден');

    final fileId = await repository.uploadAvatar(imageBytes: imageBytes, fileName: fileName);

    final updatedUser = await repository.updateAvatar(fileId: fileId);

    final localPath = await repository.avatarCache.downloadAvatar(fileId: fileId, token: currentUser.token!);

    if (currentUser.avatarFileId != null) {
      final oldPath = await repository.avatarCache.getAvatarPath(currentUser.avatarFileId!);

      await repository.avatarCache.deleteAvatar(oldPath);
    }

    final userWithLocalAvatar = updatedUser.copyWith(token: currentUser.token, avatarLocalPath: localPath);

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

    final userWithOutAvatar = User(
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
      token: updatedUser.token
    );

    _user = userWithOutAvatar;

    await repository.syncUser(userWithOutAvatar);

    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;

    await repository.deleteUser();

    notifyListeners();
  }
}