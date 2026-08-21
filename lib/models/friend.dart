import 'user.dart';

class Friend {
  final int friendshipId;
  final User user;
  final DateTime createdAt;

  const Friend({
    required this.friendshipId,
    required this.user,
    required this.createdAt,
  });

  factory Friend.fromJson(
    Map<String, dynamic> json,
  ) {
    return Friend(
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