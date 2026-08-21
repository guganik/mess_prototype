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
    final relation =
        json['relation'] as String;

    return FriendSearchResult(
      user: User.fromJson(json),
      relation: switch (relation) {
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
      },
    );
  }
}