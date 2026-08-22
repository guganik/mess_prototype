import 'package:flutter/widgets.dart';

class ChatTile extends StatefulWidget {
  @override
  ChatTileState createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
    @override
    Widget build(B)

    ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      leading: PublicUserAvatar(
        localPath: otherUser?.avatarLocalPath,
        username: otherUser?.username ?? '?',
        size: 48,
      ),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: chat.lastMessageText != null && chat.lastMessageText!.trim().isNotEmpty
        ? Text(
            chat.lastMessageText!,
            style: TextStyle(
              color: const Color.fromRGBO(75, 75, 75, 0.7)
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : otherUser != null
            ? Text(
                '@${otherUser.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const Text(
                'Нет сообщений',
              ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat.lastMessageCreatedAt != null)
            Text(
              _formatChatTime(
                chat.lastMessageCreatedAt!,
              ),
              style: const TextStyle(
                fontSize: 11,
                color: Color.fromRGBO(75, 75, 75, 0.7)
              ),
            ),
          if (otherUser != null)
            const SizedBox(height: 4),
          if (otherUser != null)
            _StatusDot(
              status: otherUser.status,
              presence: otherUser.presence,
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chat.id,
              currentUserId: context
                  .read<UserProvider>()
                  .user!
                  .id,
              otherUser: otherUser,
            ),
          ),
        );
      },
      onLongPress: otherUser == null
        ? null
        : () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (_) {
                return Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    32,
                  ),
                  child: PublicUserProfile(
                    user: otherUser!,
                  ),
                );
              },
            );
          },
    );
}