import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mess_prototype/models/app_settings.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/screens/auth_screen.dart';

import 'package:mess_prototype/screens/profile_screen.dart';
import 'package:mess_prototype/screens/settings_screen.dart';
import 'package:mess_prototype/services/connection_checker.dart';
import 'package:mess_prototype/widgets/app_text_field.dart';

import 'package:mess_prototype/widgets/change_status_button.dart';
import 'package:mess_prototype/widgets/default_button.dart';

import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final Settings settings;

  const MainScreen({
    super.key,
    required this.settings,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool pressed = false;
  bool hovered = false;


  List friends = [];
  List chats = [];
  bool loadingFriends = true;
  String? friendsError;
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    loadFriends();
  }

  Future<void> loadFriends() async {
    if (!mounted) return;

    setState(() {
      loadingFriends = false;
      friendsError = null;
      friends.clear();
      chats.clear();
    });
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // RealtimeService owns the connection/presence lifecycle.
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final currentUser = userProvider.user;

    final checker = context.watch<ConnectionChecker>();

    return Scaffold(
      body: Builder(
        builder: (context) {
          // final screenWidth = MediaQuery.of(context).size.width;
          // final screenHeight = MediaQuery.of(context).size.height;
    
          return SafeArea(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  Scaffold.of(context).openDrawer();
                }
              },
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
                              Icons.density_medium
                            )
                          ),
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                        SizedBox(width: 16,),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: const Color.fromRGBO(75, 75, 75, 0.25),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 2,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        textAlignVertical: TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                            top: 0,
                                            bottom: 0,
                                          ),
                                          isDense: true,
                                          hintText: "Поиск"
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Icon(
                                        Icons.search
                                      )
                                    ),
                                    SizedBox(width: 8,)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
                        child: loadingFriends
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : friendsError != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Не удалось загрузить чаты'),
                                    SizedBox(height: 8,),
                                    TextButton(
                                      onPressed: loadFriends,
                                      child: Text('Повторить'),
                                    ),
                                  ],
                                ),
                              )
                            : chats.isEmpty
                              ? Center(
                                  child: Text('Здесь пока тихо...'),
                                )
                              : SizedBox(),
                              // : RefreshIndicator(
                              //     onRefresh: loadFriends,
                              //     child: ListView.separated(
                              //       itemCount: chatSvc.chatList.length,
                              //       separatorBuilder: (_, __) => CustomDivider(),
                              //       itemBuilder: (context, index) {
                              //         final chat = chatSvc.chatList[index];
                                      
                              //         return ChatPreview(
                              //           key: ValueKey(chat.friendId),
                              //           friend: chat.user,
                              //           funTap: () => print('Открыть чат с ' + chat.user.username),
                              //         );
                              //       },
                              //     ),
                              //   ),
                      )
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
      drawer: LeftPanel(
        loadFriends: loadFriends,
        friends: friends,
        user: currentUser,
      ),
    );
  }
}

class LeftPanel extends StatefulWidget {
  final Function loadFriends;
  final List friends;
  final User? user;

  const LeftPanel({
    super.key,
    required this.loadFriends,
    required this.friends,
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

  final TextEditingController searchUserController = TextEditingController();

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
                        child: user!.avatarLocalPath != null
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
                  showDialog(
                    context: context,
                    builder: (_) {
                      String statusText = '';

                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('Друзья'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Найти пользователя'),
                                AppTextField(
                                  controller: searchUserController,
                                  hint: 'examp1e',
                                  prefix: '@',
                                ),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: Colors.grey[600]
                                  ),
                                ),
                                SizedBox(height: 4,),
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      statusText = 'Поиск пользователей пока не реализован';
                                    });
                                  },
                                  child: Text('Отправить приглашение')
                                ),
                              ],
                            )
                          );
                        }
                      );
                    }
                  );
                },
                label: 'Друзья',
                icon: Icons.group,
              ),
              SizedBox(),
              DefaultButton(funTap: () => print(""), label: ""),
              SizedBox(height: 8,),
              DefaultButton(funTap: () => print(""), label: ""),
              SizedBox(height: 8,),// Статус онлайна (или последнее время онлайна в случае невидимки), его редактирование
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
              DefaultButton(funTap: () => print(""), label: ""),
              SizedBox(height: 8,),
              DefaultButton(funTap: () => print(""), label: ""),
              SizedBox(height: 8,),
              DefaultButton(funTap: () => print(""), label: ""),
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
            ],
          ),
        ),
      )
    );
  }
}