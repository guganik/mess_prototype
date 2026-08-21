import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/chat.dart';

class ChatRepository {
  final ApiService apiService;

  ChatRepository({
    required this.apiService,
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
}