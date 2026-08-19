import 'dart:async';

import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

class PresenceService {
  final ApiService apiService;
  final UserRepository userRepository;

  Timer? _timer;

  PresenceService({
    required this.apiService,
    required this.userRepository
  });

  void start() {
    _sendPresence();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _sendPresence();
      }
    );
  }

  Future<void> _sendPresence() async {
    final user = await userRepository.getCurrentUser();

    if (user == null || user.token == null) return;

    try {
      final updatedUser = await apiService.updatePresence(token: user.token!);

      final syncedUser = updatedUser.copyWith(token: user.token);

      await userRepository.syncUser(syncedUser);
    } catch (e) {
      print('Presence update error: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}