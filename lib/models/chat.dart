import 'user.dart';

class ChatMessage {
  final int id;
  final int chatId;
  final int senderId;
  final String clientMessageId;
  final String text;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.clientMessageId,
    required this.text,
    required this.createdAt,
    this.editedAt,
    required this.isDeleted,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatMessage(
      id: json["id"] as int,
      chatId: json["chat_id"] as int,
      senderId: json["sender_id"] as int,
      clientMessageId:
          json["client_message_id"] as String,
      text: json["text"] as String,
      createdAt: DateTime.parse(
        json["created_at"] as String,
      ),
      editedAt: json["edited_at"] != null
          ? DateTime.parse(
              json["edited_at"] as String,
            )
          : null,
      isDeleted:
          json["is_deleted"] as bool,
    );
  }
}


class Chat {
  final int id;
  final String type;
  final String? title;
  final User? otherUser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatMessage? lastMessage;

  const Chat({
    required this.id,
    required this.type,
    this.title,
    this.otherUser,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  factory Chat.fromJson(
    Map<String, dynamic> json,
  ) {
    return Chat(
      id: json["id"] as int,
      type: json["type"] as String,
      title: json["title"] as String?,
      otherUser: json["other_user"] != null
          ? User.fromJson(
              json["other_user"]
                  as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(
        json["created_at"] as String,
      ),
      updatedAt: DateTime.parse(
        json["updated_at"] as String,
      ),
      lastMessage:
          json["last_message"] != null
              ? ChatMessage.fromJson(
                  json["last_message"]
                      as Map<String, dynamic>,
                )
              : null,
    );
  }
}