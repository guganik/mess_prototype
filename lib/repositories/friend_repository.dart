import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/friend.dart';
import 'package:mess_prototype/models/friend_request.dart';

class FriendSync {
  final List<Friend> friends;
  final List<FriendRequest> incomingRequests;
  final List<FriendRequest> outgoingRequests;

  const FriendSync({
    required this.friends,
    required this.incomingRequests,
    required this.outgoingRequests,
  });

  factory FriendSync.fromJson(
    Map<String, dynamic> json,
  ) {
    return FriendSync(
      friends: (json['friends'] as List)
          .map(
            (item) => Friend.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      incomingRequests:
          (json['incoming_requests'] as List)
              .map(
                (item) => FriendRequest.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      outgoingRequests:
          (json['outgoing_requests'] as List)
              .map(
                (item) => FriendRequest.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class FriendRepository {
  final ApiService apiService;

  FriendRepository({
    required this.apiService,
  });

  Future<FriendSync> sync({
    required String token,
  }) async {
    final data = await apiService.get(
      path: '/friends/sync',
      token: token,
    );

    return FriendSync.fromJson(data);
  }

  Future<void> sendRequest({
    required String token,
    required int userId,
  }) async {
    await apiService.post(
      path: '/friends/requests',
      token: token,
      body: {
        'user_id': userId,
      },
    );
  }

  Future<void> acceptRequest({
    required String token,
    required int friendshipId,
  }) async {
    await apiService.post(
      path: '/friends/requests/$friendshipId/accept',
      token: token,
    );
  }

  Future<void> rejectRequest({
    required String token,
    required int friendshipId,
  }) async {
    await apiService.post(
      path: '/friends/requests/$friendshipId/reject',
      token: token,
    );
  }

  Future<void> removeFriend({
    required String token,
    required int userId,
  }) async {
    await apiService.delete(
      path: '/friends/$userId',
      token: token,
    );
  }
}