import 'package:flutter/material.dart';
import 'package:mess_prototype/models/user.dart';

class ChatPreview extends StatelessWidget {
  final User friend;
  final VoidCallback funTap;

  const ChatPreview({
    super.key,
    required this.friend,
    required this.funTap
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final displayName = friend.firstName!.isNotEmpty
      ? friend.firstName
      : friend.username;

    final initial = displayName!.isNotEmpty
      ? displayName[0].toUpperCase()
      : '?';

    final statusColors = {
      'Online': Colors.green[400],
      'AFK': Colors.yellow[400],
      'DND': Colors.red[400],
      'Offline': Colors.grey[400],
    };

    return GestureDetector(
      onTap: funTap,
      child: Container(
        height: 16*4,
        width: screenWidth,
        color: Colors.transparent,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 16*4,
                  height: 16*4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(75, 75, 75, 0.35),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColors[friend.status],
                    border: BoxBorder.all(
                      color: Colors.white,
                      width: 2
                    )
                  ),
                ),
              ],
            ),
            SizedBox(width: 8,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
