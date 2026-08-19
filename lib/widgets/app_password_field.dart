import 'package:flutter/material.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;

  const AppPasswordField({
    super.key,
    required this.controller
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordField();
}

class _AppPasswordField extends State<AppPasswordField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: hidden,
      decoration: InputDecoration(
        hintText: 'Пароль',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            hidden
              ? Icons.visibility_off
              : Icons.visibility
          ),
          onPressed: () {
            setState(() {
              hidden = !hidden;
            });
          },
        ),
      ),
    );
  }
}