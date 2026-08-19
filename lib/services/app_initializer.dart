import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/app_settings.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/repositories/app_settings_repository.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

class AppInitializer {
  final ApiService _apiService;
  final UserRepository _userRepository;

  AppInitializer({
    ApiService? apiService,
    UserRepository? userRepository,
  }) : _apiService = apiService ?? ApiService(),
       _userRepository = userRepository ?? UserRepository();

  Future<User?> hasUser() async {
    final localUser = await _userRepository.getCurrentUser();

    if (localUser == null) {
      return null;
    }

    final token = localUser.token;

    if (token == null || token.isEmpty) {
      await _userRepository.deleteUser();
      return null;
    }

    try {
      final serverUser = await _apiService.getCurrentUser(token: token);

      final updatedUser = serverUser.copyWith(token: token);

      await _userRepository.updateUser(updatedUser);

      return updatedUser;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _userRepository.deleteUser();
        return null;
      }

      rethrow;
    }
  }

  Future<Settings> loadSettings() async {
    final SettingsRepository settingsRepository = SettingsRepository();

    return settingsRepository.getAppSettings();
  }

  void dispose() {
    _apiService.dispose();
  }
}