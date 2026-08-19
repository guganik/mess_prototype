// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class Switcher extends StatefulWidget {
  final VoidCallback funTap;
  int size;
  bool pressed;
  final Color? backgroundColor;
  final Color? backgroundColorPressed;
  final Color? borderColor;
  final Color? circleColor;

  Switcher({
    super.key,
    required this.funTap,
    this.size = 2,
    required this.pressed,
    this.backgroundColor = Colors.transparent,
    this.backgroundColorPressed = const Color.fromRGBO(75, 75, 75, 0.2),
    this.borderColor = const Color.fromRGBO(75, 75, 75, 0.3),
    this.circleColor = const Color.fromRGBO(75, 75, 75, 0.3)
  });

  @override
  State<Switcher> createState() => SwitcherState();
}

class SwitcherState extends State<Switcher> {
  List sizeTable = [24.0, 32.0, 38.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: widget.pressed
          ? widget.backgroundColorPressed
          : widget.backgroundColor,
        border: !widget.pressed
          ? Border.all(color: widget.borderColor!)
          : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: widget.pressed
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: widget.circleColor,
              shape: BoxShape.circle
            ),
          ),
        ],
      ) 
    );
  }
}