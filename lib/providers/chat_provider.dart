import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:mess_prototype/models/chat.dart';
import 'package:mess_prototype/repositories/chat_repository.dart';
import 'package:mess_prototype/repositories/message_repository.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/services/realtime_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;
  final UserRepository userRepository;
  final RealtimeService realtimeService;
  final MessageRepository messageRepository;

  StreamSubscription? _realtimeSubscription;

  final List<Chat> _chats = [];

  ChatProvider({
    required this.repository,
    required this.userRepository,
    required this.realtimeService,
    required this.messageRepository
  }) {
    _realtimeSubscription =
        realtimeService.events.listen(
      _handleEvent,
    );
  }

  Stream<List<LocalMessage>> watchMessages(
    int chatId,
  ) {
    return messageRepository.watchChat(
      chatId,
    );
  }

  List<Chat> get chats =>
      List.unmodifiable(_chats);

  Future<void> sync() async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    final chats =
        await repository.syncChats(
      token: token,
    );

    _replaceChats(chats);
  }

  Future<int> createDirectChat(
    int userId,
  ) async {
    final user =
        await userRepository.getCurrentUser();

    final token = user?.token;

    if (token == null || token.isEmpty) {
      throw Exception(
        "Authorization token is missing",
      );
    }

    final chatId =
        await repository.createDirectChat(
      token: token,
      userId: userId,
    );

    await sync();

    return chatId;
  }

  bool sendMessage({
    required int chatId,
    required String text,
  }) {
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      return false;
    }

    final clientMessageId =
        _generateClientMessageId();

    return realtimeService.send(
      type: "message.send",
      data: {
        "chat_id": chatId,
        "client_message_id":
            clientMessageId,
        "text": trimmed,
      },
    );
  }

  String _generateClientMessageId() {
    final random = Random.secure();

    return List.generate(
      32,
      (_) => random.nextInt(16)
          .toRadixString(16),
    ).join();
  }

  Future<void> _handleEvent(
    Map<String, dynamic> event,
  ) async {
    switch (event["type"]) {
      case "message.created":
      case "chat.created":
        await sync();
        break;
    }
  }

  void _replaceChats(
    List<Chat> chats,
  ) {
    _chats
      ..clear()
      ..addAll(chats);

    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}