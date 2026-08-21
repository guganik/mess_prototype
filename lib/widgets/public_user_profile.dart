import 'package:flutter/material.dart';

import 'package:mess_prototype/models/public_user.dart';
import 'package:mess_prototype/widgets/public_user_avatar.dart';

class PublicUserProfile extends StatelessWidget {
  final PublicUser user;
  final Widget? action;

  const PublicUserProfile({
    super.key,
    required this.user,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        user.firstName != null &&
                user.firstName!.trim().isNotEmpty
            ? user.firstName!.trim()
            : user.username;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PublicUserAvatar(
          localPath: user.avatarLocalPath,
          username: user.username,
          size: 96,
        ),

        const SizedBox(height: 16),

        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '@${user.username}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 12),

        _Presence(
          user: user,
        ),

        if (action != null) ...[
          const SizedBox(height: 20),
          action!,
        ],
      ],
    );
  }
}

class _Presence extends StatelessWidget {
  final PublicUser user;

  const _Presence({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (user.presence) {
      'online' => Colors.greenAccent,
      'away' => Colors.yellowAccent,
      _ => Colors.grey,
    };

    final text = switch (user.presence) {
      'online' => 'В сети',
      'away' => 'Отошел',
      _ => 'Не в сети',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}