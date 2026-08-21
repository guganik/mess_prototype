import 'package:flutter/material.dart';
import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/models/message_send_status.dart';
import 'package:provider/provider.dart';

import 'package:mess_prototype/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final int currentUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final TextEditingController
      _controller =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatProvider =
        context.read<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                List<LocalMessage>>(
              stream: chatProvider
                  .watchMessages(widget.chatId),
              builder: (
                context,
                snapshot,
              ) {
                final messages =
                    snapshot.data ?? const [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет сообщений',
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding:
                      const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final message =
                        messages[index];

                    final isMine =
                        message.senderId ==
                            widget.currentUserId;

                    return _MessageBubble(
                      message: message,
                      isMine: isMine,
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 5,
                      minLines: 1,
                      textInputAction:
                          TextInputAction.newline,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Сообщение...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                    ),
                    onPressed: () async {
                      final text =
                          _controller.text;

                      _controller.clear();

                      final user =
                          context
                              .read<ChatProvider>();

                      await user.sendMessage(
                        chatId: widget.chatId,
                        senderId:
                            widget.currentUserId,
                        text: text,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}


class _MessageBubble
    extends StatelessWidget {
  final LocalMessage message;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        constraints:
            const BoxConstraints(
          maxWidth: 320,
        ),
        decoration:
            BoxDecoration(
          color: isMine
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.messageText,
              ),
            ),
            const SizedBox(height: 4),
            _Status(
              status: MessageSendStatus.values.firstWhere(
                (value) => value.name == message.sendStatus,
                orElse: () => MessageSendStatus.sent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _Status extends StatelessWidget {
  final MessageSendStatus status;

  const _Status({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageSendStatus.sending:
        return const Icon(
          Icons.schedule,
          size: 14,
        );

      case MessageSendStatus.sent:
        return const Icon(
          Icons.done,
          size: 14,
        );

      case MessageSendStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 14,
        );
    }
  }
}