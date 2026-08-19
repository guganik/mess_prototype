// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class DefaultButton extends StatefulWidget {
  final VoidCallback funTap;
  final String label;
  final IconData? icon;
  final Color? defaultColor;
  final Color? defaultColorHover;
  final Color? defaultColorPressed;
  int size;

  DefaultButton({
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
  State<DefaultButton> createState() => _DefaultButtonState();
}

class _DefaultButtonState extends State<DefaultButton> {
  List sizeTable = [24.0, 32.0, 38.0];
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
          pressed = false;
        });
      },

      child: GestureDetector(
        onTap: widget.funTap,

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

        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          height: sizeTable[widget.size-1],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color:
              pressed
              ? widget.defaultColorPressed
              : hovered
                ? widget.defaultColorHover
                : widget.defaultColor
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
              )
            ],
          ),
        )
      )
    );
  }
}