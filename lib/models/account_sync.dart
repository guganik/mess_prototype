import 'package:mess_prototype/models/chat.dart';
import 'package:mess_prototype/models/user.dart';

class AccountSync {
  final User user;
  final List<Chat> chats;

  const AccountSync({
    required this.user,
    required this.chats,
  });

  factory AccountSync.fromJson(
    Map<String, dynamic> json,
  ) {
    final userData = json['user'];

    if (userData is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid account sync user',
      );
    }

    final chatsData = json['chats'];

    if (chatsData is! List) {
      throw const FormatException(
        'Invalid account sync chats',
      );
    }

    return AccountSync(
      user: User.fromJson(userData),
      chats: chatsData
          .map(
            (item) => Chat.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}