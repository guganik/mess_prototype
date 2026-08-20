// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:mess_prototype/widgets/back_arrow.dart';
import 'package:mess_prototype/widgets/switcher_button.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  BackArrow(),
                  Spacer(),
                ],
              ),
              SizedBox(height: 32,),
              Column(
                children: [
                  SwitcherButton(
                    size: 1,
                    pressed: false,
                    funTap: () {},
                    label: 'Тестовый свитчер'
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}