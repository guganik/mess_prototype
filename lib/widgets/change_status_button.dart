import 'package:flutter/material.dart';

class ChangeStatusButton extends StatefulWidget {
  final String statusText;
  final Color statusColor;
  final GestureTapCallback funTap;

  const ChangeStatusButton({
    super.key,
    required this.statusColor,
    required this.statusText,
    required this.funTap
  });

  @override
  State<ChangeStatusButton> createState() => _ChangeStatusButtonState();
}

class _ChangeStatusButtonState extends State<ChangeStatusButton> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hovered = true;
        });
      },

      onExit: (event) {
        setState(() {
          hovered = false;
        });
      },

      child: GestureDetector(
        onTap: widget.funTap,
        child: Column(
          children: [
            SizedBox(height: 4,),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.statusColor,
                  ),
                ),
                SizedBox(width: 4,),
                Text(
                  widget.statusText,
                  style: TextStyle(
                    fontSize: 14
                  ),
                ),
              ],
            ),
            SizedBox(width: 2,),
            AnimatedContainer(
              height: 2,
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: hovered
                  ? const Color.fromRGBO(75, 75, 75, 0.2)
                  : const Color.fromRGBO(75, 75, 75, 0),
                borderRadius: BorderRadius.all(Radius.circular(50))
              ),
            ),
          ]
        ),
      )
    );
  }
}