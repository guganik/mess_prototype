import 'package:mess_prototype/models/public_user.dart';

enum FriendRelation {
  none,
  pendingIncoming,
  pendingOutgoing,
  friends,
  rejected,
  blocked,
}

class FriendSearchResult {
  final PublicUser user;
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
      user: PublicUser.fromJson(json),
      relation: relation,
    );
  }
}