import 'package:mess_prototype/models/user.dart';

class AccountSync {
  final User user;

  const AccountSync({
    required this.user,
  });

  factory AccountSync.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];

    if (userData is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid account sync response',
      );
    }

    return AccountSync(
      user: User.fromJson(userData),
    );
  }
}