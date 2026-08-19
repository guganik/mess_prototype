import 'package:flutter/material.dart';
import 'package:mess_prototype/models/user.dart';

class FriendRequest extends StatefulWidget {
  final User friend;
  final GestureTapCallback funTap;

  const FriendRequest({
    super.key,
    required this.friend,
    required this.funTap
  });

  @override
  _FriendRequestState createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  @override
  Widget build(BuildContext context) {
    final displayName = widget.friend.firstName!.isNotEmpty
        ? widget.friend.firstName
        : widget.friend.username;

    final initial = displayName!.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 16*2,
            height: 16*2,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(75, 75, 75, 0.35),
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8,),
          widget.friend.firstName!.isNotEmpty
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.firstName!,
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  '@${widget.friend.username}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600]!
                  ),
                )
              ],
            )
            : Text(
              '@${widget.friend.username}',
              style: TextStyle(fontSize: 14),
            ),
          Spacer(),
          GestureDetector(
            onTap: widget.funTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.grey[700]!, width: 2)
              ),
              child: Icon(
                Icons.add
              ),
            ),
          ),
          SizedBox(width: 8,)
        ],
      ),
    );
  }
}