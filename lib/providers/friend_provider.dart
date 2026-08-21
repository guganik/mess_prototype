import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mess_prototype/models/friend.dart';
import 'package:mess_prototype/models/friend_request.dart';
import 'package:mess_prototype/models/friend_search_result.dart';
import 'package:mess_prototype/models/public_user.dart';
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

  String _lastSearchQuery = '';

  final Set<int> _sendingRequestUserIds = {};

  bool isSendingRequest(int userId) {
    return _sendingRequestUserIds.contains(userId);
  }

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

  List<Friend> get friends => List.unmodifiable(_friends);

  List<FriendRequest> get incomingRequests => List.unmodifiable(_incomingRequests);

  List<FriendRequest> get outgoingRequests => List.unmodifiable(_outgoingRequests);

  bool get loading => _loading;

  List<FriendSearchResult> _searchResults = [];

  bool _searchLoading = false;

  List<FriendSearchResult> get searchResults => List.unmodifiable(_searchResults);

  bool get searchLoading => _searchLoading;

  Future<void> searchUsers(
    String query,
  ) async {
    final normalized = query.trim();

    _lastSearchQuery = normalized;

    if (normalized.isEmpty) {
      _searchResults = [];
      _searchLoading = false;
      notifyListeners();
      return;
    }

    final user = await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    _searchLoading = true;
    notifyListeners();

    try {
      final results = await repository.searchUsers(
        token: token,
        query: normalized,
      );

      final hydratedResults = <FriendSearchResult>[];

      for (final result in results) {
        hydratedResults.add(
          FriendSearchResult(
            user: await _hydrateUserAvatar(
              result.user,
              token,
            ),
            relation: result.relation,
          ),
        );
      }

      _searchResults = hydratedResults;
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

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

      final hydratedFriends = <Friend>[];

      for (final friend in sync.friends) {
        hydratedFriends.add(
          Friend(
            friendshipId: friend.friendshipId,
            user: await _hydrateUserAvatar(
              friend.user,
              token,
            ),
            createdAt: friend.createdAt,
          ),
        );
      }

      final hydratedIncoming = <FriendRequest>[];

      for (final request
          in sync.incomingRequests) {
        hydratedIncoming.add(
          FriendRequest(
            friendshipId:
                request.friendshipId,
            user: await _hydrateUserAvatar(
              request.user,
              token,
            ),
            createdAt:
                request.createdAt,
          ),
        );
      }

      final hydratedOutgoing = <FriendRequest>[];

      for (final request
          in sync.outgoingRequests) {
        hydratedOutgoing.add(
          FriendRequest(
            friendshipId:
                request.friendshipId,
            user: await _hydrateUserAvatar(
              request.user,
              token,
            ),
            createdAt:
                request.createdAt,
          ),
        );
      }

      _friends = hydratedFriends;
      _incomingRequests = hydratedIncoming;
      _outgoingRequests = hydratedOutgoing;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sendRequest(
    int userId,
  ) async {
    if (_sendingRequestUserIds.contains(userId)) {
      return;
    }

    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    _sendingRequestUserIds.add(userId);
    notifyListeners();

    try {
      await repository.sendRequest(
        token: token,
        userId: userId,
      );

      await refresh();

      final currentQuery = _lastSearchQuery;

      if (currentQuery.isNotEmpty) {
        await searchUsers(currentQuery);
      }
    } finally {
      _sendingRequestUserIds.remove(userId);
      notifyListeners();
    }
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

  Future<PublicUser> _hydrateUserAvatar(
    PublicUser user,
    String token,
  ) async {
    if (user.avatarFileId == null ||
        user.avatarFileId!.isEmpty) {
      return user.copyWith(
        avatarLocalPath: null,
      );
    }

    try {
      final localPath =
          await userRepository.avatarCache
              .downloadAvatar(
        fileId: user.avatarFileId!,
        token: token,
      );

      return user.copyWith(
        avatarLocalPath: localPath,
      );
    } catch (error) {
      debugPrint(
        'Не удалось загрузить аватар @${user.username}: $error',
      );

      return user;
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}