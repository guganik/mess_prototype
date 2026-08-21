import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:mess_prototype/models/chat.dart';
import 'package:mess_prototype/repositories/chat_repository.dart';
import 'package:mess_prototype/repositories/message_repository.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/services/realtime_service.dart';
import 'package:mess_prototype/database/app_database.dart';

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

  Future<void> sendMessage({
    required int chatId,
    required int senderId,
    required String text,
  }) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      return;
    }

    final clientMessageId =
        _generateClientMessageId();

    final localId =
        await messageRepository.insertSendingMessage(
      chatId: chatId,
      senderId: senderId,
      clientMessageId: clientMessageId,
      messageText: trimmed,
      createdAt: DateTime.now(),
    );

    final sent = realtimeService.send(
      type: 'message.send',
      data: {
        'chat_id': chatId,
        'client_message_id':
            clientMessageId,
        'text': trimmed,
      },
    );

    if (!sent) {
      await messageRepository.markAsFailed(
        localId,
      );
    }
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
    switch (event['type']) {
      case 'message.created':
        await _handleMessageCreated(
          event['data']
            as Map<String, dynamic>,
        );
        break;

      case 'chat.created':
        await sync();
        break;
    }
  }

  Future<void> _handleMessageCreated(
    Map<String, dynamic> data,
  ) async {
    final message =
        ChatMessage.fromJson(data);

    final existing =
        await messageRepository
            .findByClientMessageId(
      message.clientMessageId,
    );

    if (existing != null) {
      await messageRepository.markAsSent(
        localId: existing.localId,
        serverId: message.id,
      );

      return;
    }

    await messageRepository.insertServerMessage(
      serverId: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      clientMessageId:
          message.clientMessageId,
      messageText: message.text,
      createdAt: message.createdAt,
      editedAt: message.editedAt,
      isDeleted: message.isDeleted,
    );
  }

  void _replaceChats(
    List<Chat> chats,
  ) {
    _chats
      ..clear()
      ..addAll(chats);

    notifyListeners();
  }

  Stream<List<LocalChat>> watchChats() {
    return repository.watchChats();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}