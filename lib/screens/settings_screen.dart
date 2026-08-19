// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/widgets/back_arrow.dart';
import 'package:mess_prototype/widgets/switcher_button.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserRepository userRepository = UserRepository();
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    final user = userProvider.user;

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