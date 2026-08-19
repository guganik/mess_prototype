import 'package:flutter/foundation.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

class UserSyncService extends ChangeNotifier {
  final ApiService _apiService;
  final UserRepository _userRepository;

  User? _user;

  bool _isSyncing = false;
  String? _error;

  UserSyncService({
    ApiService? apiService,
    UserRepository? userRepository,
  }) : _apiService = apiService ?? ApiService(),
       _userRepository = userRepository ?? UserRepository();

  User? get user => _user;

  bool get isSyncing => _isSyncing;

  String? get error => _error;

  Future<User?> loadLocalUser() async {
    final user = await _userRepository.getCurrentUser();

    _user = user;

    notifyListeners();

    return user;
  }

  Future<User?> syncUser() async {
    if (isSyncing) {
      return _user;
    }

    final localUser = _user ?? await _userRepository.getCurrentUser();

    if (localUser == null) {
      _user = null;
      notifyListeners();

      return null;
    }

    final token = localUser.token;

    if (token == null || token.isEmpty) {
      _error = 'User token is missing';

      _user = localUser;

      notifyListeners();

      return localUser;
    }

    _isSyncing = true;
    _error = null;

    notifyListeners();

    try {
      final serverUser = await _apiService.getCurrentUser(token: token);

      final updatedUser = await _userRepository.syncAvatar(localUser, serverUser.copyWith(token: token));

      await _userRepository.updateUser(updatedUser);

      _user = updatedUser;

      return updatedUser;
    } on ApiException catch (e) {
      _error = e.toString();

      rethrow;
    } catch (e) {
      _error = e.toString();

      rethrow;
    } finally {
      _isSyncing = false;

      notifyListeners();
    }
  }

  Future<User?> updateUser({
    String? firstName,
    String? email,
    String? phone,
    String? status,
  }) async {
    final currentUser = _user ?? await _userRepository.getCurrentUser();

    if (currentUser == null) return null;

    final token = currentUser.token;

    if (token == null || token.isEmpty) return currentUser;

    _isSyncing = true;
    _error = null;

    notifyListeners();

    try {
      final updatedUser = await _apiService.updateCurrentUser(
        token: token,
        firstName: firstName,
        email: email,
        phone: phone,
        status: status
      );

      final userWithToken = updatedUser.copyWith(token: token, avatarLocalPath: currentUser.avatarLocalPath);

      await _userRepository.updateUser(userWithToken);

      _user = userWithToken;

      return userWithToken;
    } on ApiException catch (e) {
      _error = e.toString();

      rethrow;
    } catch (e) {
      _error = e.toString();

      rethrow;
    } finally {
      _isSyncing = false;

      notifyListeners();
    }
  }

  Future<void> clearUser() async {
    await _userRepository.deleteUser();

    _user = null;
    _error = null;
    
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();

    super.dispose();
  }
}