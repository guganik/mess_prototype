import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mess_prototype/controllers/auth_controller.dart';
import 'package:mess_prototype/models/user.dart';
import 'package:mess_prototype/providers/user_provider.dart';
import 'package:mess_prototype/services/is_valid_values.dart';
import 'package:mess_prototype/widgets/back_arrow.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController controller = AuthController();
  final IsValidValues isValidValues = IsValidValues();

  final MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
    mask: '### ### ##-##',
    filter: {"#": RegExp(r'[0-9]')}
  );

  bool isSaving = false;
  bool hovered = false;

  String usernameError = '';
  String firstNameError = '';
  String emailError = '';
  String phoneError = '';

  bool get hasErrors => 
    usernameError.isNotEmpty ||
    firstNameError.isNotEmpty ||
    emailError.isNotEmpty ||
    phoneError.isNotEmpty;

  User? get currentUser {return context.read<UserProvider>().user;}

  bool get hasChanges {
    final user = currentUser;

    if (user == null) return false;

    final username = controller.username.trim();
    final firstName = controller.firstName.trim();
    final email = controller.email.trim();
    final phone = controller.phone.trim();

    return username.isNotEmpty && username != user.username ||
      firstName.isNotEmpty && firstName != (user.firstName ?? '') ||
      email.isNotEmpty && email != (user.email ?? '') ||
      phone.isNotEmpty && phone != (user.phone ?? '');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _validateUsername() {
    final value = controller.username;

    if (value.isEmpty) {
      usernameError = '';
      return;
    }

    usernameError = isValidValues.username(value) ?? '';
  }

  void _validateFirstName() {
    firstNameError = isValidValues.firstName(controller.firstName) ?? '';
  }

  void _validateEmail() {
    final value = controller.email;

    if (value.isEmpty) {
      emailError = '';
      return;
    }

    emailError = isValidValues.email(value) ?? '';
  }

  void _validatePhone() {
    final value = controller.phone;

    if (value.isEmpty) {
      phoneError = '';
      return;
    }

    phoneError = isValidValues.phone(phoneFormatter) ?? '';
  }

  void _validateAll() {
    _validateUsername();
    _validateFirstName();
    _validateEmail();
    _validatePhone();
  }

  Map<String, String> _buildChanges(User user) {
    final changes = <String, String>{};

    final username = controller.username.trim();
    final firstName = controller.firstName.trim();
    final email = controller.email.trim();
    final phone = controller.phone.trim();

    if (username.isNotEmpty && username != user.username) {
      changes['username'] = username;
    }

    if (firstName.isNotEmpty && firstName != user.firstName) {
      changes['first_name'] = firstName;
    }
    
    if (email.isNotEmpty && email != (user.email ?? '')) {
      changes['email'] = email;
    }
    
    if (phone.isNotEmpty && phone != (user.phone ?? '')) {
      changes['phone'] = phone;
    }

    return changes;
  }

  Future<void> _saveProfile() async {
    if (isSaving) return;

    final user = currentUser;
    if (user == null) return;

    setState(_validateAll);

    if (hasErrors || !hasChanges) return;

    final changes = _buildChanges(user);
    if (changes.isEmpty) return;

    setState(() {
      isSaving = true;
    });

    try {
      await context.read<UserProvider>().updateProfile(
        username: changes['username'],
        firstName: changes['first_name'],
        email: changes['email'],
        phone: changes['phone'] != null || changes['phone'] != '' ? phoneFormatter.unmaskText(changes['phone']!) : '',
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;


    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Пользователь не найден'),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: screenWidth,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  BackArrow(),
                  SizedBox(width: 16,),
                  Text(
                    'Редактирование профиля',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 32,),
              Container(
                padding: EdgeInsets.all(16),
                width: screenWidth * 0.6,
                constraints: BoxConstraints(
                  maxWidth: 600,
                  minWidth: 400
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(75, 75, 75, 75),
                      blurRadius: 4
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.usernameController,
                      decoration: InputDecoration(
                        prefixText: '@',
                        hintText: user.username,
                        labelText: 'Имя пользователя',
                        errorText: usernameError.isNotEmpty
                          ? usernameError
                          : null,
                            
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _validateUsername();
                        });
                      },
                    ),
                    SizedBox(height: 8,),
                    TextField(
                      controller: controller.firstNameController,
                      decoration: InputDecoration(
                        hintText: user.firstName ?? 'Введите свое имя',
                        labelText: 'Имя',
                        errorText: firstNameError.isNotEmpty 
                          ? firstNameError
                          : null,
                            
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _validateFirstName();
                        });
                      },
                    ),
                    SizedBox(height: 8,),
                    Text(
                      'Обязательные поля!',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 32,),
              Container(
                padding: EdgeInsets.all(16),
                width: screenWidth * 0.6,
                constraints: BoxConstraints(
                  maxWidth: 600,
                  minWidth: 400
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(75, 75, 75, 75),
                      blurRadius: 4
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.emailController,
                      decoration: InputDecoration(
                        hintText: user.email ?? 'example@example.com',
                        labelText: 'Почта',
                        errorText: emailError.isNotEmpty
                          ? emailError
                          : null,
                            
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _validateEmail();
                        });
                      },
                    ),
                    SizedBox(height: 8,),
                    TextField(
                      inputFormatters: [phoneFormatter],
                      keyboardType: TextInputType.phone,
                      controller: controller.phoneController,
                      decoration: InputDecoration(
                        hintText: user.phone != null
                          ? phoneFormatter.maskText(user.phone!)
                          : '987 654 32-10',
                        labelText: 'Номер телефона',

                        prefixText: '+7 ',

                        errorText: phoneError.isNotEmpty
                          ? phoneError
                          : null,
                            
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _validatePhone();
                        });
                      },
                    ),
                    SizedBox(height: 8,),
                    Text(
                      'Необязательные поля',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14
                      ),
                    )
                  ],
                ),
              ),
              Spacer(),
              MouseRegion(
                onEnter: (event) {
                  setState(() {  
                    hovered = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    hovered = false;
                  });
                },
                child: GestureDetector(
                  onTap: _saveProfile,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasChanges && !hasErrors && !isSaving
                      ? hovered
                        ? Colors.grey[500]
                        : Colors.grey[400]
                      : Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(30))
                    ),
                    child: Text(
                      isSaving 
                        ? 'Сохранение...'
                        : 'Применить изменения',
                      style: TextStyle(
                        fontSize: 16,
                        color: hasChanges && !hasErrors && !isSaving
                          ? Colors.black
                          : Colors.grey[600],
                      ),
                    )
                  ),
                ),
              )
            ],
          )
        )
      )
    );
  }
}