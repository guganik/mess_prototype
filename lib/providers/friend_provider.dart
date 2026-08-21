import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mess_prototype/models/friend.dart';
import 'package:mess_prototype/models/friend_request.dart';
import 'package:mess_prototype/models/friend_search_result.dart';
import 'package:mess_prototype/repositories/friend_repository.dart';
import 'package:mess_prototype/services/realtime_service.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

class FriendProvider extends ChangeNotifier {
  final FriendRepository repository;
  final UserRepository userRepository;
  final RealtimeService realtimeService;

  StreamSubscription? _realtimeSubscription;

  List<Friend> _friends = [];
  List<FriendRequest> _incomingRequests = [];
  List<FriendRequest> _outgoingRequests = [];

  bool _loading = false;

  FriendProvider({
    required this.repository,
    required this.userRepository,
    required this.realtimeService,
  }) {
    _realtimeSubscription =
        realtimeService.events.listen(
      _handleEvent,
    );
  }

  List<Friend> get friends =>
      List.unmodifiable(_friends);

  List<FriendRequest> get incomingRequests =>
      List.unmodifiable(_incomingRequests);

  List<FriendRequest> get outgoingRequests =>
      List.unmodifiable(_outgoingRequests);

  bool get loading => _loading;

  List<FriendSearchResult> _searchResults = [];

  bool _searchLoading = false;

  List<FriendSearchResult> get searchResults => List.unmodifiable(_searchResults);

  bool get searchLoading => _searchLoading;

  Future<void> refresh() async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final sync = await repository.sync(
        token: token,
      );

      _friends = sync.friends;
      _incomingRequests =
          sync.incomingRequests;
      _outgoingRequests =
          sync.outgoingRequests;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sendRequest(
    int userId,
  ) async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    await repository.sendRequest(
      token: token,
      userId: userId,
    );

    await refresh();
  }

  Future<void> acceptRequest(
    int friendshipId,
  ) async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    await repository.acceptRequest(
      token: token,
      friendshipId: friendshipId,
    );

    await refresh();
  }

  Future<void> rejectRequest(
    int friendshipId,
  ) async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    await repository.rejectRequest(
      token: token,
      friendshipId: friendshipId,
    );

    await refresh();
  }

  Future<void> removeFriend(
    int userId,
  ) async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    await repository.removeFriend(
      token: token,
      userId: userId,
    );

    await refresh();
  }

  Future<void> _handleEvent(
    Map<String, dynamic> event,
  ) async {
    final type = event['type'];

    switch (type) {
      case 'friend.requested':
      case 'friend.updated':
      case 'friend.request.rejected':
      case 'friend.removed':
        await refresh();
        break;
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}