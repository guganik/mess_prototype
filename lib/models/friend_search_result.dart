import 'package:mess_prototype/models/user.dart';

enum FriendRelation {
  none,
  pendingIncoming,
  pendingOutgoing,
  friends,
  rejected,
  blocked,
}

class FriendSearchResult {
  final User user;
  final FriendRelation relation;

  const FriendSearchResult({
    required this.user,
    required this.relation,
  });

  factory FriendSearchResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final relationValue =
        json['relation'] as String? ?? 'none';

    final relation = switch (relationValue) {
      'pending_incoming' =>
        FriendRelation.pendingIncoming,
      'pending_outgoing' =>
        FriendRelation.pendingOutgoing,
      'friends' =>
        FriendRelation.friends,
      'rejected' =>
        FriendRelation.rejected,
      'blocked' =>
        FriendRelation.blocked,
      _ => FriendRelation.none,
    };

    return FriendSearchResult(
      user: User(
        id: json['id'] as int,
        username: json['username'] as String,
        firstName: json['first_name'] as String?,
        email: null,
        phone: null,
        avatarFileId:
            json['avatar_file_id'] as String?,
        avatarLocalPath: null,
        status: json['status'] as String,
        presence: json['presence'] as String,
        lastSeen: json['last_seen'] != null
            ? DateTime.tryParse(
                json['last_seen'] as String,
              )
            : null,
        isActive: true,
        token: null,
      ),
      relation: relation,
    );
  }
}