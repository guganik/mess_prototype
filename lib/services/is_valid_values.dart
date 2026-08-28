import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class IsValidValues {
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 32;
  
  static const int firstNameMaxLength = 32;

  static const Set<String> reservedUsernames = {
    'admin',
    'administrator',
    'moderator',
    'support',
    'help',
    'system',
    'root',
    'bot',
    'official'
  };

  static final  RegExp _usernamePattern = RegExp(r'^[a-z0-9_]+$');

  String? username(String value) {
    final username = value.trim();

    if (username.isEmpty) return 'Имя пользователя не может быть пустым';

    if (username.length < usernameMinLength) return 'Имя пользователя должно быть минимум $usernameMinLength символа';

    if (username.length >usernameMaxLength) return 'Имя пользователя не может превышать $usernameMaxLength символов';

    if(username != username.toLowerCase()) return 'Имя пользователя может содержать только строчные символы';

    if (!_usernamePattern.hasMatch(username)) return 'Имя пользователя может содержать только английские буквы, цифры и "_"';

    if (reservedUsernames.contains(username)) return 'Это имя пользователя недоступно';

    return null;
  }
  
  String? firstName(String value) {
    final firstName = value.trim();

    if (firstName.isEmpty) return 'Имя не может быть пустым';

    if (firstName.length > firstNameMaxLength) return 'Имя пользователя не должно превышать $firstNameMaxLength символов';

    return null;
  }

  String? email(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (!emailRegex.hasMatch(email)) return 'Некорректный адрес';
    
    return null;
  }

  String? phone(MaskTextInputFormatter formatter) {
    final clearPhone = formatter.getUnmaskedText();

    if (clearPhone.isEmpty) return 'Номер телефона не может быть пустым';

    if (clearPhone.length < 10) return 'Номер телефона слишком короткий';
    if (clearPhone.length > 15) return 'Номер телефона слишком длинный';

    return null;
  }
}