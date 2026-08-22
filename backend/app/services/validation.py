from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.user import User

def validate_username_unique(db: Session, username: str, exclude_user_id: int | None = None) -> None:
    query = select(User).where(User.username == username)

    if exclude_user_id is not None:
        query = query.where(User.id != exclude_user_id)

    if db.scalar(query) is not None:
        raise ValueError('Username is already registered')

def validate_email_unique(db: Session, email: str, exclude_user_id: int | None = None) -> None:
    query = select(User).where(User.email == email)

    if exclude_user_id is not None:
        query = query.where(User.id != exclude_user_id)

    if db.scalar(query) is not None:
        raise ValueError('Email is already registered')

def validate_phone_unique(db: Session, phone: str, exclude_user_id: int | None = None) -> None:
    query = select(User).where(User.phone == phone)

    if exclude_user_id is not None:
        query = query.where(User.id != exclude_user_id)

    if db.scalar(query) is not None:
        raise ValueError('Phone is already registered')