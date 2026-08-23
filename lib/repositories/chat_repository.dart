import 'package:drift/drift.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/models/chat.dart';
import 'package:mess_prototype/repositories/message_repository.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

class ChatRepository {
  final ApiService apiService;
  final UserRepository userRepository;
  final MessageRepository messageRepository;
  final AppDatabase database;

  ChatRepository({
    required this.apiService,
    required this.userRepository,
    required this.messageRepository,
    required this.database
  });

  Future<List<Chat>> syncChats({
    required String token,
  }) async {
    final chats = await apiService.syncChats(
      token: token,
    );

    for (final chat in chats) {
      await database
          .into(database.localChats)
          .insertOnConflictUpdate(
        LocalChatsCompanion(
          id: Value(chat.id),
          type: Value(chat.type),
          otherUserId: Value(
            chat.otherUser?.id,
          ),
          title: Value(chat.title),
          createdAt: Value(chat.createdAt),
          updatedAt: Value(chat.updatedAt),
          lastMessageId: Value(
            chat.lastMessage?.id,
          ),
          lastMessageText: Value(
            chat.lastMessage?.text,
          ),
          lastMessageSenderId: Value(
            chat.lastMessage?.senderId,
          ),
          lastMessageCreatedAt: Value(
            chat.lastMessage?.createdAt,
          ),
        ),
      );
    }

    return chats;
  }

  Future<int> createDirectChat({
    required String token,
    required int userId,
  }) {
    return apiService.createDirectChat(
      token: token,
      userId: userId,
    );
  }

  Future<void> loadMessages(
    int chatId, {
    int? beforeId,
  }) async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authorization token is missing',
      );
    }

    final messages = await apiService.getMessages(
      token: token,
      chatId: chatId,
      beforeId: beforeId,
    );

    for (final message in messages) {
      await messageRepository.insertServerMessage(
        serverId: message.id,
        chatId: message.chatId,
        senderId: message.senderId,
        clientMessageId: message.clientMessageId,
        messageText: message.text,
        createdAt: message.createdAt,
        editedAt: message.editedAt,
        isDeleted: message.isDeleted,
      );
    }
  }

  Stream<List<LocalChat>> watchChats() {
    return (
      database.select(database.localChats)
        ..orderBy([
          (table) => OrderingTerm(
            expression: table.updatedAt,
            mode: OrderingMode.desc,
          ),
        ])
    ).watch();
  }

  Future<void> updateChatPreview({
    required int chatId,
    required int messageId,
    required int senderId,
    required String text,
    required DateTime createdAt,
  }) async {
    await (
      database.update(
        database.localChats,
      )..where(
        (table) => table.id.equals(chatId),
      )
    ).write(
      LocalChatsCompanion(
        updatedAt: Value(createdAt),
        lastMessageId: Value(messageId),
        lastMessageSenderId: Value(senderId),
        lastMessageText: Value(text),
        lastMessageCreatedAt: Value(createdAt),
      ),
    );
  }

  Future<void> clearLocalChats() async {
    await database.delete(
      database.localMessages,
    ).go();

    await database.delete(
      database.localChatMembers,
    ).go();

    await database.delete(
      database.localChats,
    ).go();
  }
}