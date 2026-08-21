import 'package:flutter/material.dart';
import 'package:mess_prototype/providers/chat_provider.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/widgets/public_user_tile.dart';
import 'package:provider/provider.dart';

import 'package:mess_prototype/providers/friend_provider.dart';
import 'package:mess_prototype/screens/chat_screen.dart';

class FriendsScreen
    extends StatefulWidget {
  const FriendsScreen({
    super.key,
  });

  @override
  State<FriendsScreen> createState() =>
      _FriendsScreenState();
}

class _FriendsScreenState
    extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context
          .read<FriendProvider>()
          .refresh();
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        context.watch<FriendProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Друзья',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(
          padding:
              const EdgeInsets.all(16),
          children: [
            if (provider
                .incomingRequests
                .isNotEmpty)
              _IncomingRequests(
                provider: provider,
              ),

            if (provider
                .outgoingRequests
                .isNotEmpty)
              _OutgoingRequests(
                provider: provider,
              ),

            const SizedBox(height: 16),

            const Text(
              'Друзья',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (provider.friends.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 24,
                ),
                child: Center(
                  child: Text(
                    'Пока нет друзей',
                  ),
                ),
              )
            else
              ...provider.friends.map(
                (friend) {
                  final user = friend.user;

                  return PublicUserTile(
                    user: user,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.message,
                      ),
                      onPressed: () async {
                        final chatId = await context.read<ChatProvider>().createDirectChat(user.id,);

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              currentUserId: context.read<UserProvider>().user!.id,
                              otherUser: user,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingRequests
    extends StatelessWidget {
  final FriendProvider provider;

  const _IncomingRequests({
    required this.provider,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Входящие заявки',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ...provider
            .incomingRequests
            .map(
              (request) => Card(
                child: PublicUserTile(
                  user: request.user,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                        ),
                        onPressed: () {
                          provider.acceptRequest(
                            request.friendshipId,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                        ),
                        onPressed: () {
                          provider.rejectRequest(
                            request.friendshipId,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _OutgoingRequests
    extends StatelessWidget {
  final FriendProvider provider;

  const _OutgoingRequests({
    required this.provider,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        const Text(
          'Исходящие заявки',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        ...provider
          .outgoingRequests
          .map(
            (request) => PublicUserTile(
              user: request.user,
              trailing: const Text(
                'Ожидает ответа',
              ),
            ),
          ),
      ],
    );
  }
}