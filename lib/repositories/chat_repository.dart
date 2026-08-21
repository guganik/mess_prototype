import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/chat.dart';
import 'package:mess_prototype/repositories/message_repository.dart';
import 'package:mess_prototype/repositories/user_repository.dart';

class ChatRepository {
  final ApiService apiService;
  final UserRepository userRepository;
  final MessageRepository messageRepository;

  ChatRepository({
    required this.apiService,
    required this.userRepository,
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
        clientMessageId: message.clientMessageId,
        messageText: message.text,
        createdAt: message.createdAt,
        editedAt: message.editedAt,
        isDeleted: message.isDeleted,
      );
    }
  }
}