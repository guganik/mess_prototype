import re

USERNAME_MIN_LENGTH = 3
USERNAME_MAX_LENGTH = 32

FIRST_NAME_MAX_LENGTH = 32

EMAIL_MAX_LENGTH = 10

PHONE_MIN_LENGTH = 10
PHONE_MAX_LENGTH = 15

USERNAME_PATTERN = re.compile(r'^[a-z0-9_]+$')

EMAIL_PATTERN = re.compile(r"^[a-zA-Z0-9.!#%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$")

PHONE_PATTERN = re.compile(r"^\+?[0-9]+$")

RESERVED_USERNAMES = {
    'admin',
    'administrator',
    'moderator',
    'support',
    'help',
    'system',
    'root',
    'bot',
    'official'
}

def validate_username(username: str) -> str:
    if not isinstance(username, str):
        raise ValueError('Username должен быть строкой')

    if not username:
        raise ValueError('Username не может быть пустым')

    if len(username) < USERNAME_MIN_LENGTH:
        raise ValueError(f'Username должен содержать минимум {USERNAME_MIN_LENGTH} символа')

    if len(username) > USERNAME_MAX_LENGTH:
        raise ValueError(f'Username не должен превышать {USERNAME_MAX_LENGTH} символов')
    
    if username.lower() != username:
        raise ValueError('Username может содержать только строчные символы')

    if not USERNAME_PATTERN.fullmatch(username):
        raise ValueError('Username должен содержать только английские буквы, цифры и символ "_"')

    if username in RESERVED_USERNAMES:
        raise ValueError('Этот username недоступен')

    return username

def validate_first_name(value: str | None) -> str | None:
    if value is None: return None

    value = value.strip()

    if not value:
        raise ValueError('First name не может быть пустым')

    if len(value) > FIRST_NAME_MAX_LENGTH:
        raise ValueError(f'First name не может превышать {FIRST_NAME_MAX_LENGTH} символов')

    return value

def validate_email(value: str | None) -> str | None:
    if value is None: return None

    value = value.strip()

    if not value: raise ValueError('Email не может быть пустым')

    if len(value) > EMAIL_MAX_LENGTH: raise ValueError(f'Email не может превышать {EMAIL_MAX_LENGTH} символов')

    if not EMAIL_PATTERN.fullmatch(value): raise ValueError('Некорректный email')

    return value

def validate_phone(value: str | None) -> str | None:
    if value is None: return None

    value = value.strip()

    if not value: raise ValueError('Phone не может быть пустым')

    if not PHONE_PATTERN.fullmatch(value): raise ValueError('Phone может содержать только цифры и обязательный символ "+" в начале')

    digits = value.lstrip('+')

    if len(digits) < PHONE_MIN_LENGTH: raise ValueError(f'Phone должен содержать минимум {PHONE_MIN_LENGTH} цифр')

    if len(digits) > PHONE_MAX_LENGTH: raise ValueError(f'Phone не должен превышать {PHONE_MAX_LENGTH} цифр')

    return value