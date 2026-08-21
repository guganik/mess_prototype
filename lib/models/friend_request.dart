import 'user.dart';

class FriendRequest {
  final int friendshipId;
  final User user;
  final DateTime createdAt;

  const FriendRequest({
    required this.friendshipId,
    required this.user,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return FriendRequest(
      friendshipId:
          json['friendship_id'] as int,
      user: User.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }
}