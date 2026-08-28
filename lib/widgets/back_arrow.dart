import 'package:flutter/material.dart';

class BackArrow extends StatelessWidget {
  const BackArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(16),
        width: 32,
        height: 32,
        child: Icon(Icons.arrow_back)
      )
    );
  }
}