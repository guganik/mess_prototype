// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class Switcher extends StatefulWidget {
  final VoidCallback funTap;
  int size;
  final Color? backgroundColor;
  final Color? backgroundColorPressed;
  final Color? borderColor;
  final Color? circleColor;

  Switcher({
    super.key,
    required this.funTap,
    this.size = 2,
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
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: widget.backgroundColor!),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.circleColor,
          shape: BoxShape.circle
        ),
      ),
    );
  }
}