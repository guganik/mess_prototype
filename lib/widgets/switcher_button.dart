// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mess_prototype/widgets/switcher.dart';

class SwitcherButton extends StatefulWidget {
  final VoidCallback funTap;
  final String label;
  final IconData? icon;
  final Color? defaultColor;
  final Color? defaultColorHover;
  final Color? defaultColorPressed;
  int size;

  SwitcherButton({
    super.key,
    required this.funTap,
    required this.label,
    this.icon,
    this.size = 2,
    this.defaultColor = Colors.transparent,
    this.defaultColorHover = const Color.fromRGBO(75, 75, 75, 0.2),
    this.defaultColorPressed = const Color.fromRGBO(75, 75, 75, 0.3)
  });

  @override
  State<SwitcherButton> createState() => SwitcherButtonState();
}

class SwitcherButtonState extends State<SwitcherButton> {
  List sizeTable = [24.0, 32.0, 38.0];
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      height: sizeTable[widget.size-1],
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: widget.defaultColor
      ),
      child: Row(
        children: [
          widget.icon != null ? Icon(widget.icon) : SizedBox(),
          SizedBox(width: 4,),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14
            ),
          ),
          Spacer(),
          Switcher(
            funTap: () {print('Нажат свитчер');},
            pressed: false,
          ),
          SizedBox(width: 4,),
        ],
      ),
    );
  }
}