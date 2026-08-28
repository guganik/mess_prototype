import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:mess_prototype/database/app_database.dart';

import 'package:mess_prototype/models/app_settings.dart';
import 'package:mess_prototype/models/friend_search_result.dart';
import 'package:mess_prototype/models/public_user.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/providers/chat_provider.dart';
import 'package:mess_prototype/providers/friend_provider.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/screens/auth_screen.dart';
import 'package:mess_prototype/screens/chat_screen.dart';
import 'package:mess_prototype/screens/friends_screen.dart';

import 'package:mess_prototype/screens/profile_screen.dart';
import 'package:mess_prototype/screens/settings_screen.dart';
import 'package:mess_prototype/services/connection_checker.dart';

import 'package:mess_prototype/widgets/change_status_button.dart';
import 'package:mess_prototype/widgets/default_button.dart';
import 'package:mess_prototype/widgets/divider.dart';
import 'package:mess_prototype/widgets/public_user_avatar.dart';
import 'package:mess_prototype/widgets/public_user_profile.dart';
import 'package:mess_prototype/widgets/public_user_tile.dart';
import 'package:mess_prototype/widgets/slide_drawer.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  final Settings settings;

  const MainScreen({
    super.key,
    required this.settings,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool pressed = false;
  bool hovered = false;

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  bool get isSearching => _searchController.text.trim().isNotEmpty;

  final SlideDrawerController _drawerController = SlideDrawerController();
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<ChatProvider>().sync();
      context.read<FriendProvider>().refresh();
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});

    _searchDebounce?.cancel();

    final query =
        _searchController.text.trim();

    if (query.isEmpty) {
      context.read<FriendProvider>().searchUsers('');

      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) {
          return;
        }

        context.read<FriendProvider>().searchUsers(query);
      },
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final currentUser = userProvider.user;

    final checker = context.watch<ConnectionChecker>();

    return Scaffold(
      body: SlideDrawer(
        controller: _drawerController,
        drawer: LeftPanel(user: currentUser),
        child: Builder(
          builder: (context) {
            // final screenWidth = MediaQuery.of(context).size.width;
            // final screenHeight = MediaQuery.of(context).size.height;
      
            return SafeArea(
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                Icons.density_medium,
                                color: const Color.fromRGBO(75, 75, 75, 0.7),
                              )
                            ),
                            onTap: () {
                              _drawerController.open();
                            },
                          ),
                          SizedBox(width: 16,),
                          Expanded(
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: const Color.fromRGBO(75, 75, 75, 0.15),
                              ),
                              child: SizedBox(
                                height: 32,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Transform.translate(
                                        offset: Platform.isAndroid
                                          ? const Offset(0, 0)
                                          : const Offset(0, -4),
                                        child: TextField(
                                          controller: _searchController,
                                          textAlignVertical: TextAlignVertical.center,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            hintText: 'Поиск...',
                                            hintStyle: TextStyle(
                                              color: Color.fromRGBO(75, 75, 75, 0.7)
                                            )
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.search,
                                      size: 24,
                                      color: Color.fromRGBO(75, 75, 75, 0.5),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              )
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 16,),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            scrollbarTheme: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.dragged)) {
                                  return const Color.fromARGB(115, 75, 75, 75);
                                }
                                if (states.contains(WidgetState.hovered)) {
                                  return const Color.fromARGB(100, 75, 75, 75);
                                }
                                return const Color.fromARGB(75, 75, 75, 75);
                              }),
                              thickness: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.dragged)) {
                                  return 5;
                                }
                                return 4;
                              }),
                            )
                          ),
                          child: _searchController.text.trim().isNotEmpty
                            ? _FriendSearchResults()
                            : _ChatList(),
                        ),
                      ),
                      Row(
                        children: [
                          AnimatedSize(
                            alignment: Alignment.centerRight,
                            duration: Duration(milliseconds: 300),
                            child: Container(
                              padding: !checker.isConnected
                                ? EdgeInsets.only(right: 9)
                                : null,
                              width: checker.isConnected
                                ? 36
                                : null,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromRGBO(15, 15, 15, 0.2),
                                    blurRadius: 7
                                  )
                                ]
                              ),
                              child: checker.isConnected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent[400]!,
                                )
                              : Row(
                                children: [
                                  SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: CircularProgressIndicator(
                                      padding: EdgeInsets.all(9),
                                    ),
                                  ),
                                  SizedBox(width: 8,),
                                  Text('Соединение...')
                                ],
                              )
                            )
                          ),
                          Spacer()
                        ],
                      )
                    ],
                  )
                )
              ),
            );
          }
        ),
      )
    );
  }
}

class LeftPanel extends StatefulWidget {
  final User? user;

  const LeftPanel({
    super.key,
    required this.user,
  });

  @override
  LeftPanelState createState() => LeftPanelState();
}

class LeftPanelState extends State<LeftPanel> {
  bool hovered = false;
  bool pressed = false;

  bool pressedChangeStatus = false;
  
  final statusColors = {
    'online': Colors.green[400],
    'away': Colors.yellow[400],
    'do_not_disturb': Colors.red[400],
    'offline': Colors.grey[400],
  };

  @override
  void initState() {
    super.initState();
  }

  Future<void> changeStatus(String status, BuildContext context) async {
    try {
      await context.read<UserProvider>().setStatus(status);

      if (!mounted) return;
      setState(() {
        pressedChangeStatus = false;
      });
    } catch (e) {
      debugPrint('Не удалось изменить статус: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final user = userProvider.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Drawer(
        width: 300,
        shape: Platform.isAndroid
        ? RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(16)
          )
        )
        : null,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 16*4,
                        height: 16*4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromRGBO(75, 75, 75, 0.35),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: user.avatarLocalPath != null
                          ? Image.file(
                              File(user.avatarLocalPath!),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColors[user.status],
                          border: BoxBorder.all(
                            color: Colors.white,
                            width: 2
                          )
                        ),
                      ),
                    ]
                  ),
                  SizedBox(width: 8,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        user.firstName != null && user.firstName!.isNotEmpty
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.firstName!,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
                        : Text(
                            user.username,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          )
                      ],
                    )
                  )
                ]
              ),
              SizedBox(height: 32,),
              DefaultButton(
                funTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen()
                    )
                  );
                },
                label: "Профиль",
                icon: Icons.person,
              ),
              SizedBox(height: 4,),
              DefaultButton(
                funTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen()
                    )
                  );
                },
                label: "Настройки",
                icon: Icons.settings_rounded,
              ),
              SizedBox(height: 4,),
              DefaultButton(
                funTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FriendsScreen(),
                    ),
                  );
                },
                label: 'Друзья',
                icon: Icons.group,
              ),
              SizedBox(height: 4,),
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    hovered = !pressedChangeStatus;
                  });
                },
                onExit: (event) {
                  setState(() {
                    hovered = false;
                    pressed = false;
                  });
                },

                child: GestureDetector(
                  onTap: () {
                    pressedChangeStatus = !pressedChangeStatus;
                    if (Platform.isWindows) hovered = !pressedChangeStatus;
                  },

                  onTapDown: (details) {
                    setState(() {
                      pressed = true;
                    });
                  },

                  onTapUp: (details) {
                    setState(() {
                      pressed = false;
                    });
                  },

                  onTapCancel: () {
                    setState(() {
                      pressed = false;
                    });
                  },

                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedSize(
                      alignment: Alignment.topCenter,
                      duration: Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        height: pressedChangeStatus
                          ? null
                          : 32,
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: pressed
                            ? const Color.fromRGBO(75, 75, 75, 0.3)
                            : hovered && !pressedChangeStatus
                              ? const Color.fromRGBO(75, 75, 75, 0.2)
                              : const Color.fromRGBO(75, 75, 75, 0)
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Изменить статус',
                                  style: TextStyle(
                                    fontSize: 14
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  pressedChangeStatus
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                                  size: 14,
                                )
                              ],
                            ),
                            if (pressedChangeStatus)
                            Column(
                              children: [
                                ChangeStatusButton(
                                  statusColor: Colors.greenAccent[400]!,
                                  statusText: 'В сети',
                                  funTap: () => changeStatus('online', context)
                                ),
                                ChangeStatusButton(
                                  statusColor: Colors.yellowAccent[400]!,
                                  statusText: 'Отошел',
                                  funTap: () => changeStatus('away', context)
                                ),
                                ChangeStatusButton(
                                  statusColor: Colors.redAccent[400]!,
                                  statusText: 'Не беспокоить',
                                  funTap: () => changeStatus('do_not_disturb', context)
                                ),
                                ChangeStatusButton(
                                  statusColor: Colors.grey[400]!,
                                  statusText: 'Не в сети',
                                  funTap: () => changeStatus('offline', context)
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  )
                ),
              ),
              Spacer(),
              DefaultButton(
                funTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final screenHeight = MediaQuery.of(context).size.height;
                      return Dialog(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.9,
                          constraints: BoxConstraints(
                            maxWidth: 600,
                            minWidth: 400,
                            maxHeight: 1000,
                            minHeight: 400
                          ),
                          child: Column(
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Text('Что за обнова?'),
                                    SizedBox(height: 4,),
                                    Expanded(
                                      child: FutureBuilder<String>(
                                        future: _loadChangelog(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }

                                          if (snapshot.hasError) {
                                            return const Center(
                                              child: Text(
                                                'Не удалось загрузить список обновлений',
                                              ),
                                            );
                                          }

                                          return SingleChildScrollView(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: MarkdownBody(
                                              data: snapshot.data ?? '',
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              SizedBox(height: 8,),
                              DefaultButton(
                                funTap: checkForUpdates,
                                label: 'Проверить обновления',
                                icon: Icons.replay_outlined,
                              )
                            ],
                          )
                        )
                      );
                    }
                  );
                },
                label: 'Обновления',
                icon: Icons.system_update,
              ),
              SizedBox(height: 8,),
              DefaultButton(
                funTap: () async {
                  await context.read<UserProvider>().logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (_) => false,
                  );
                },
                label: "Выйти",
                defaultColor: const Color.fromRGBO(220, 5, 5, 0.5),
                defaultColorHover: const Color.fromRGBO(200, 5, 5, 0.7),
                defaultColorPressed: const Color.fromRGBO(180, 5, 5, 0.75),
              ),
              SizedBox(height: 4,),
              Text(
                'Version 1.0.5.0',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500]
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class _FriendSearchResults
    extends StatelessWidget {
  const _FriendSearchResults();

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        context.watch<FriendProvider>();

    if (provider.searchLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Пользователи не найдены',
        ),
      );
    }

    return ListView.separated(
      itemCount:
          provider.searchResults.length,
      separatorBuilder: (_, _) =>
          const Divider(
        height: 1,
      ),
      itemBuilder: (
        context,
        index,
      ) {
        final result =
            provider.searchResults[index];

        return _FriendSearchTile(
          result: result,
        );
      },
    );
  }
}

class _FriendSearchTile extends StatelessWidget {
  final FriendSearchResult result;

  const _FriendSearchTile({
    required this.result,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        context.read<FriendProvider>();

    final user = result.user;

    Widget action;

    switch (result.relation) {
      case FriendRelation.none:
        action = TextButton(
          onPressed: provider.isSendingRequest(user.id)
              ? null
              : () {
                  provider.sendRequest(user.id);
                },
          child: provider.isSendingRequest(user.id)
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Добавить',
                ),
        );
        break;

      case FriendRelation.pendingOutgoing:
        action = const Text(
          'Заявка отправлена',
        );
        break;

      case FriendRelation.pendingIncoming:
        action = TextButton(
          onPressed: () {
            // Здесь позже можно открыть
            // конкретную заявку.
          },
          child: const Text(
            'Есть заявка',
          ),
        );
        break;

      case FriendRelation.friends:
        action = const Text(
          'Друзья',
        );
        break;

      case FriendRelation.rejected:
        action = const Text(
          'Отклонено',
        );
        break;

      case FriendRelation.blocked:
        action = const Text(
          'Заблокирован',
        );
        break;
    }

    return PublicUserTile(
      user: user,
      trailing: action,
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                12,
                24,
                32,
              ),
              child: PublicUserProfile(
                user: user,
              ),
            );
          },
        );
      },
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LocalChat>>(
      stream: context.read<ChatProvider>().watchChats(),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final chats = snapshot.data ?? const [];

        if (chats.isEmpty) {
          return const Center(
            child: Text(
              'Здесь пока тихо...',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(
            bottom: 8,
          ),
          itemCount: chats.length,
          separatorBuilder: (
            context,
            index,
          ) {
            return CustomDivider();
          },
          itemBuilder: (
            context,
            index,
          ) {
            final chat = chats[index];

            return _ChatListTile(
              chat: chat,
            );
          },
        );
      },
    );
  }
}

class _ChatListTile extends StatefulWidget {
  final LocalChat chat;

  const _ChatListTile({
    required this.chat,
  });

  @override
  _ChatListTileState createState() => _ChatListTileState();
}

class _ChatListTileState extends State<_ChatListTile> {
  bool chatHovered = false;

  @override
  Widget build(BuildContext context) {

    final friendProvider = context.watch<FriendProvider>();

    PublicUser? otherUser;

    for (final friend in friendProvider.friends) {
      if (friend.user.id == widget.chat.otherUserId) {
        otherUser = friend.user;
        break;
      }
    }

    final displayName = otherUser != null
      ? (
        otherUser.firstName != null && otherUser.firstName!.trim().isNotEmpty
          ? otherUser.firstName!.trim()
          : '@${otherUser.username}'
      )
      : 'Чат';

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          chatHovered = true;
        });
      },

      onExit: (event) {
        setState(() {
          chatHovered = false;
        });
      },

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatId: widget.chat.id,
                currentUserId: context.read<UserProvider>().user!.id,
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
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: PublicUserProfile(
                    user: otherUser!,
                  ),
                );
              },
            );
          },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: chatHovered
              ? Color.fromRGBO(75, 75, 75, 0.15)
              : Colors.transparent,
          ),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentGeometry.topRight,
                children: [
                  PublicUserAvatar(
                    localPath: otherUser?.avatarLocalPath,
                    username: otherUser?.username ?? '?',
                    size: 52,
                  ),
                  if (otherUser != null)
                  Container(
                    height: 14,
                    width: 14,
                    decoration: BoxDecoration(
                      color: _statusDot(status: otherUser.status, presence: otherUser.presence),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)
                    ),
                  )
                ],
              ),
              SizedBox(width: 8,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName),
                    SizedBox(height: 4,),
                    widget.chat.lastMessageText != null && widget.chat.lastMessageText!.trim().isNotEmpty
                      ? Text(
                          widget.chat.lastMessageText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(''),
                  ],
                ),
              ),
              SizedBox(width: 8,),
              Column(
                children: [
                  if (widget.chat.lastMessageCreatedAt != null)
                  Text(
                    _formatChatTime(widget.chat.lastMessageCreatedAt!)
                  ),
                ],
              ),
              SizedBox(width: 4,)
            ],
          )
        )
      )
    );
  }

  String _formatChatTime(
    DateTime dateTime,
  ) {
    final now = DateTime.now();

    final sameDay =
        now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;

    if (sameDay) {
      final hour = dateTime.hour
          .toString()
          .padLeft(2, '0');

      final minute = dateTime.minute
          .toString()
          .padLeft(2, '0');

      return '$hour:$minute';
    }

    return '${dateTime.day}.${dateTime.month}';
  }
}

Color _statusDot({
  required String presence,
  required String status
}) {
  Color color;

  if (presence == 'online') {
    color = switch (status) {
      'online' => Colors.greenAccent,
      'away' => Colors.yellowAccent,
      'do_not_disturb' => Colors.redAccent,
      _ => Colors.grey
    };
  } else {
    color = Colors.grey;
  }

  return color;
}

Future<void> checkForUpdates() async {
  final uri = Uri.parse(
    'ms-appinstaller:?source=https://googa-talk.ru/downloads/mess_prototype.appinstaller',
  );

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Не удалось открыть App Installer');
  }
}

Future<String> _loadChangelog() async {
  final response = await http.get(
    Uri.parse(
      'https://googa-talk.ru/downloads/changelog.md',
    ),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Не удалось загрузить список обновлений',
    );
  }

  return response.body;
}