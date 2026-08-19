// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/repositories/user_repository.dart';
import 'package:mess_prototype/widgets/back_arrow.dart';

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

    print(user!.username);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: 
    
    );
    Scaffold(
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
						Container(
							child: Column(
								children: [
									Row(
										children: [
											Container(
												width: 16*7,
												height: 16*7,
												decoration: BoxDecoration(
													color: const Color.fromRGBO(75, 75, 75, 0.35),
													shape: BoxShape.circle
												),
											),
											SizedBox(width: 16,),
											Expanded(
												child: SizedBox(
													height: 16*7,
													child: Column(
														children: [
															Container(
																height: 32,
																color: const Color.fromRGBO(75, 75, 75, 0.35),
															),
															SizedBox(height: 16,),
															Container(
																height: 64,
																color: const Color.fromRGBO(75, 75, 75, 0.35),
															)
														],
													)
												),
											)
										],
									),
									SizedBox(height: 64,),
									Container(
										height: 32,
										color: const Color.fromRGBO(75, 75, 75, 0.35),
									),
									SizedBox(height: 16,),
									Container(
										height: 32,
										color: const Color.fromRGBO(75, 75, 75, 0.35),
									),
									SizedBox(height: 16,),
									Container(
										height: 32,
										color: const Color.fromRGBO(75, 75, 75, 0.35),
									),
									SizedBox(height: 16,),
									Container(
										height: 32,
										color: const Color.fromRGBO(75, 75, 75, 0.35),
									),
									SizedBox(height: 16,),
									Container(
										height: 32,
										color: const Color.fromRGBO(75, 75, 75, 0.35),
									),
									SizedBox(height: 16,),
									Container(
										height: 32,
										color: const Color.fromRGBO(75, 75, 75, 0.35),
									),
									SizedBox(height: 16,),
									Container(
										height: 32,
										color: const Color.fromRGBO(75, 75, 75, 0.35),
									),
								],
							),
						),
					],
				),
			),
    );
  }
}