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

  void _updatePublicUserInCollections(
    int userId, {
    String? presence,
    String? status,
    DateTime? lastSeen,
  }) {
    _friends = _friends.map((friend) {
      if (friend.user.id != userId) {
        return friend;
      }

      return Friend(
        friendshipId: friend.friendshipId,
        createdAt: friend.createdAt,
        user: friend.user.copyWith(
          presence: presence,
          status: status,
          lastSeen: lastSeen,
        ),
      );
    }).toList();

    _incomingRequests =
        _incomingRequests.map((request) {
      if (request.user.id != userId) {
        return request;
      }

      return FriendRequest(
        friendshipId: request.friendshipId,
        createdAt: request.createdAt,
        user: request.user.copyWith(
          presence: presence,
          status: status,
          lastSeen: lastSeen,
        ),
      );
    }).toList();

    _outgoingRequests =
        _outgoingRequests.map((request) {
      if (request.user.id != userId) {
        return request;
      }

      return FriendRequest(
        friendshipId: request.friendshipId,
        createdAt: request.createdAt,
        user: request.user.copyWith(
          presence: presence,
          status: status,
          lastSeen: lastSeen,
        ),
      );
    }).toList();

    _searchResults =
        _searchResults.map((result) {
      if (result.user.id != userId) {
        return result;
      }

      return FriendSearchResult(
        relation: result.relation,
        user: result.user.copyWith(
          presence: presence,
          status: status,
          lastSeen: lastSeen,
        ),
      );
    }).toList();
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
    final data = event['data'];

    if (type is! String ||
        data is! Map<String, dynamic>) {
      return;
    }

    switch (type) {
      case 'friend.requested':
      case 'friend.updated':
      case 'friend.request.rejected':
      case 'friend.removed':
        await refresh();
        break;

      case 'presence.updated':
        final userId = data['user_id'];

        if (userId is! int) {
          return;
        }

        DateTime? lastSeen;

        final rawLastSeen = data['last_seen'];

        if (rawLastSeen is String) {
          lastSeen = DateTime.tryParse(rawLastSeen);
        }

        _updatePublicUserInCollections(
          userId,
          presence: data['presence'] as String?,
          lastSeen: lastSeen,
        );

        notifyListeners();
        break;

      case 'status.updated':
        final userId = data['user_id'];

        if (userId is! int) {
          return;
        }

        _updatePublicUserInCollections(
          userId,
          status: data['status'] as String?,
        );

        notifyListeners();
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