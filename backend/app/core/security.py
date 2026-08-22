from datetime import datetime, timedelta, timezone

from argon2 import PasswordHasher
from jose import JWTError, jwt

from app.config import settings

password_hasher = PasswordHasher()

def hash_password(password: str) -> str:
    return password_hasher.hash(password)

def verify_password(password: str, password_hash: str) -> bool:
    try:
        password_hasher.verify(password_hash, password)

        return True
    except:
        return False

def create_access_token(user_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    payload = {
        'sub': str(user_id),
        'exp': expire
    }

    return jwt.encode(
        payload,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )

def decode_access_token(token: str) -> int:
    payload = jwt.decode(
        token,
        settings.SECRET_KEY,
        algorithms=[settings.ALGORITHM]
    )

    subject = payload.get('sub')

    if subject is None:
        raise JWTError('Token does not contain user id')
    
    return int(subject)