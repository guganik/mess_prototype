import 'package:flutter/material.dart';

import 'package:mess_prototype/models/public_user.dart';
import 'package:mess_prototype/widgets/public_user_avatar.dart';

class PublicUserTile extends StatelessWidget {
  final PublicUser user;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PublicUserTile({
    super.key,
    required this.user,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        user.firstName != null &&
                user.firstName!.trim().isNotEmpty
            ? user.firstName!.trim()
            : '@${user.username}';

    return ListTile(
      leading: PublicUserAvatar(
        localPath: user.avatarLocalPath,
        username: user.username,
        size: 48,
      ),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '@${user.username}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _statusText(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  String _statusText() {
    if (user.presence == 'online') {
      switch (user.status) {
        case 'online':
          return 'В сети';

        case 'away':
          return 'Отошел';

        case 'do_not_disturb':
          return 'Не беспокоить';

        case 'offline':
          return 'Не в сети';

        default:
          return user.status;
      }
    } else {
      return 'Не в сети';
    }
  }
}