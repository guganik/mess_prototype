from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.user import User, UserStatus
from app.schemas.auth import UserRegister
from app.services.validation import (
    validate_username_unique,
    validate_email_unique,
    validate_phone_unique
)

def register_user(db: Session, user_data: UserRegister) -> User:
    validate_username_unique(db, user_data.username)

    if user_data.email is not None:
        validate_email_unique(db, user_data.email)
    
    if user_data.phone is not None:
        validate_phone_unique(db, user_data.phone)

    user = User(
        username=user_data.username,
        first_name=user_data.first_name,
        email=user_data.email,
        phone=user_data.phone,
        status=UserStatus.OFFLINE,
        password_hash=hash_password(user_data.password),
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user

def authenticate_user(db: Session, username: str, password: str) -> User | None:
    user = db.scalar(
        select(User).where(User.username == username)
    )

    if user is None:
        return None
    
    if not verify_password(password, user.password_hash):
        return None
    
    return user