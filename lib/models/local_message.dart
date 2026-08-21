enum MessageSendStatus {
  sending,
  sent,
  failed,
}

class LocalMessage {
  final int localId;
  final int? serverId;
  final int chatId;
  final int senderId;
  final String clientMessageId;
  final String text;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final MessageSendStatus sendStatus;

  const LocalMessage({
    required this.localId,
    required this.serverId,
    required this.chatId,
    required this.senderId,
    required this.clientMessageId,
    required this.text,
    required this.createdAt,
    required this.editedAt,
    required this.isDeleted,
    required this.sendStatus,
  });
}