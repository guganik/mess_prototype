import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/chat.dart';
import 'package:mess_prototype/repositories/message_repository.dart';

class ChatRepository {
  final ApiService apiService;
  final MessageRepository messageRepository;

  ChatRepository({
    required this.apiService,
    required this.messageRepository,
  });

  Future<List<Chat>> syncChats({
    required String token,
  }) {
    return apiService.syncChats(
      token: token,
    );
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

  Future<List<ChatMessage>> getMessages({
    required String token,
    required int chatId,
    int limit = 50,
    int? beforeId,
  }) {
    return apiService.getMessages(
      token: token,
      chatId: chatId,
      limit: limit,
      beforeId: beforeId,
    );
  }

  Future<List<ChatMessage>> loadMessages(
    int chatId, {
    int? beforeId,
  }) async {
    final user = await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authorization token is missing',
      );
    }

    final messages =
        await apiService.getMessages(
      token: token,
      chatId: chatId,
      beforeId: beforeId,
    );

    for (final message in messages) {
      await messageRepository.insertServerMessage(
        serverId: message.id,
        chatId: message.chatId,
        senderId: message.senderId,
        clientMessageId:
            message.clientMessageId,
        text: message.text,
        createdAt: message.createdAt,
        editedAt: message.editedAt,
        isDeleted: message.isDeleted,
      );
    }

    return messages;
  }
}