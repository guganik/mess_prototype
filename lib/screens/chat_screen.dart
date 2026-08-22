import 'package:flutter/material.dart';
import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/models/message_send_status.dart';
import 'package:mess_prototype/models/public_user.dart';
import 'package:mess_prototype/providers/friend_provider.dart';
import 'package:mess_prototype/widgets/public_user_avatar.dart';
import 'package:mess_prototype/widgets/public_user_profile.dart';
import 'package:provider/provider.dart';

import 'package:mess_prototype/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final int currentUserId;
  final PublicUser? otherUser;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    this.otherUser
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _loadingHistory = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _loadHistory();
      },
    );
  }

  PublicUser? _getCurrentOtherUser(
    BuildContext context,
  ) {
    final initialUser = widget.otherUser;

    if (initialUser == null) {
      return null;
    }

    final friends = context.watch<FriendProvider>().friends;

    for (final friend in friends) {
      if (friend.user.id == initialUser.id) {
        return friend.user;
      }
    }

    return initialUser;
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loadingHistory = true;
    });

    try {
      await context.read<ChatProvider>().loadMessages(
        widget.chatId,
      );
    } catch (error) {
      debugPrint(
        'Не удалось загрузить историю чата: $error',
      );
    } finally {
      setState(() {
        _loadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();

    final otherUser = _getCurrentOtherUser(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _ChatHeader(
          user: otherUser,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<LocalMessage>>(
              stream: chatProvider.watchMessages(widget.chatId),
              builder: (
                context,
                snapshot,
              ) {
                final messages = snapshot.data ?? const [];

                if (_loadingHistory && messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Нет сообщений'),
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
                      final text = _controller.text;

                      _controller.clear();

                      final user = context.read<ChatProvider>();

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

class _ChatHeader extends StatelessWidget {
  final PublicUser? user;

  const _ChatHeader({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    
    if (user == null) {
      return const Text(
        'Чат',
      );
    }

    final displayName = user!.firstName != null && user!.firstName!.trim().isNotEmpty
      ? user!.firstName!.trim()
      : '@${user!.username}';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) {
            return Consumer<FriendProvider>(
              builder: (
                context,
                friendProvider,
                child,
              ) {
                PublicUser? currentUser = user;

                for (final friend
                    in friendProvider.friends) {
                  if (friend.user.id == user!.id) {
                    currentUser = friend.user;
                    break;
                  }
                }

                if (currentUser == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    32,
                  ),
                  child: PublicUserProfile(
                    user: currentUser,
                  ),
                );
              },
            );
          },
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          children: [
            PublicUserAvatar(
              localPath: user!.avatarLocalPath,
              username: user!.username,
              size: 40,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor(
                            user!.presence,
                            user!.status
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        _statusText(
                          user!.presence,
                          user!.status
                        ),
                        style:
                            const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(
    String presence,
    String status
  ) {
    if (status != 'offline' && presence != 'offline') {
      return switch (status) {
        'online' => Colors.greenAccent,
        'away' => Colors.yellowAccent,
        'do_not_disturb' => Colors.redAccent,
        _ => Colors.grey,
      };
    } else {
      return Colors.grey;
    }
  }

  String _statusText(
    String presence,
    String status
  ) {
    if (status != 'offline' && presence != 'offline') {
      return switch (status) {
        'online' => 'В сети',
        'away' => 'Отошел',
        'do_not_disturb' => 'Не беспокоить',
        _ => 'Не в сети',
      };
    } else {
      return 'Не в сети';
    }
  }
}