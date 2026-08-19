import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/screens/avatar_editor_screen.dart';
import 'package:mess_prototype/screens/edit_profile_screen.dart';
import 'package:mess_prototype/widgets/back_arrow.dart';
import 'package:mess_prototype/widgets/default_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  bool _avatarHovered = false;
  bool _avatarHolding = false;
  double _deleteProgress = 0.0;

  Timer? _deleteTimer;
  DateTime? _holdStartTime;

  void _startAvatarHold() {
    if (context.read<UserProvider>().user?.avatarFileId == null) return;

    _deleteTimer?.cancel();

    _holdStartTime = DateTime.now();

    setState(() {
      _avatarHolding = true;
      _deleteProgress = 0.0;
    });

    _deleteTimer = Timer.periodic(
      Duration(milliseconds: 16),
      (_) {
        final start = _holdStartTime;

        if (start == null || !mounted) return;

        final elapsed = DateTime.now().difference(start).inMilliseconds;
        final progress = (elapsed / 2000.0).clamp(0.0, 1.0);

        setState(() {
          _deleteProgress = progress;
        });

        if (progress >= 1.0) {
          _deleteTimer?.cancel();
          _deleteAvatar();
        }
      }
    );
  }

  void _cancelAvatarHold() {
    _deleteTimer?.cancel();
    _holdStartTime = null;

    if (!mounted) return;

    setState(() {
      _avatarHolding = false;
      _deleteProgress = 0.0;
    });
  }

  Future<void> _deleteAvatar() async {
    _deleteTimer?.cancel();
    _holdStartTime = null;

    if (!mounted) return;

    setState(() {
      _avatarHolding = false;
      _deleteProgress = 1.0;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final updatedUser = await userProvider.repository.deleteAvatar();
      
      print(updatedUser.avatarFileId);
      print(updatedUser.avatarLocalPath);
      await userProvider.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Аватар успешно обновлен')));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось удалить аватар')));
    } finally {
      if (mounted) {
        setState(() {
          _deleteProgress = 0.0;
        });
      }
    }
  }

  Future<void> _changeAvatar() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    if (!mounted) return;

    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarEditorScreen(
          imageBytes: bytes
        )
      )
    );

    if (result == null || !mounted) return;

    try {
      final userProvider = context.read<UserProvider>();

      await userProvider.setAvatar(imageBytes: result, fileName: 'avatar.png');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Аватар успешно обновлен')));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось загрузить аватар')));
    }
  }

  @override
  void dispose() {
    _deleteTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
						Row(
							children: [
								BackArrow(),
								Spacer(),
							],
						),
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  _avatarHovered = true;
                });
              },
              onExit: (_) {
                if (!_avatarHolding) {
                  setState(() {
                    _avatarHovered = false;
                  });
                }
              },
              child: GestureDetector(
                onTap: _changeAvatar,
                onLongPressStart: (_) {
                  _startAvatarHold();
                },
                onLongPressEnd: (_) {
                  if (_deleteProgress < 1.0) {
                    _cancelAvatarHold();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 16 * 10,
                      height: 16 * 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: user!.avatarLocalPath != null
                        ? Image.file(
                          File(user.avatarLocalPath!),
                          fit: BoxFit.cover,
                        )
                        : Container(
                            color: const Color.fromRGBO(
                              75,
                              75,
                              75,
                              0.35,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 16 * 6,
                            ),
                          ),
                    ),

                    if (_avatarHovered || _avatarHolding)
                      AnimatedContainer(
                        duration: _avatarHolding
                            ? const Duration(milliseconds: 50)
                            : const Duration(milliseconds: 300),
                        width: 16 * 10,
                        height: 16 * 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            Colors.black.withValues(alpha: 0.45),
                            Colors.red.withValues(alpha: 0.85),
                            _deleteProgress.clamp(0.0, 1.0),
                          ),
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: Color.lerp(
                                Colors.white,
                                Colors.brown.shade900,
                                _deleteProgress.clamp(0.0, 1.0),
                              ),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            child: const Text(
                              'Нажатие — изменить\n'
                              'Удержание — удалить',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16,),
            Text(
              user.firstName != null && user.firstName!.isNotEmpty
                ? user.firstName!
                : user.username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
            Text(
              '@${user.username}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600]!
              ),
            ),
            SizedBox(height: 32,),
            Container(
              height: 16*8,
              color: const Color.fromRGBO(75, 75, 75, 0.35),
            ),
            SizedBox(height: 16,),
            DefaultButton(
              funTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen()
                  )
                );
              },
              label: 'Редактировать профиль',
              icon: Icons.edit,
            ),
            SizedBox(height: 16,),
            Container(
              height: 32,
              color: const Color.fromRGBO(75, 75, 75, 0.35),
            ),
            SizedBox(height: 16,),
            Container(
              height: 32,
              color: const Color.fromRGBO(75, 75, 75, 0.35),
            ),
            SizedBox(height: 16,),
            Container(
              height: 32,
              color: const Color.fromRGBO(75, 75, 75, 0.35),
            ),
          ],
        ),
      ),
    );
  }
}