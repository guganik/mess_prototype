import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String prefix;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefix = ''
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        border: const OutlineInputBorder()
      ),
    );
  }
}