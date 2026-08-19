import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8,),
        Container(
          height: 2,
          color: const Color.fromRGBO(75, 75, 75, 0.2),
        ),
        SizedBox(height: 8,),
      ]
    );
  }
}