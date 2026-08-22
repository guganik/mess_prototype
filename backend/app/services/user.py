from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.user import User
from app.models.file import File
from app.schemas.user import UserUpdate
from app.services.validation import (
    validate_username_unique,
    validate_email_unique,
    validate_phone_unique
)
from app.storage import file_storage

def update_user(db: Session, user: User, user_data: UserUpdate) -> User:
    update_data = user_data.model_dump(exclude_unset=True)

    if 'username' in update_data:
        validate_username_unique(db, update_data['username'], exclude_user_id=user.id)

    if 'email' in update_data:
        validate_email_unique(db, update_data['email'], exclude_user_id=user.id)

    if 'phone' in update_data:
        validate_phone_unique(db, update_data['phone'], exclude_user_id=user.id)

    for field, value in update_data.items():
        setattr(user, field, value)

    db.commit()
    db.refresh(user)

    return user

def update_avatar(db: Session, user: User, file_id: str) -> User:
    file = db.scalar(select(File).where(File.file_id == file_id))

    if file is None:
        raise ValueError('File not found')

    if file.owner_id != user.id:
        raise ValueError('Access denied')

    user.avatar_file_id = file.id

    delete_avatar(db, user)

    db.commit()
    db.refresh(user)

    return user

def delete_avatar(db: Session, user: User) -> User:
    avatar = user.avatar_file

    if avatar is None:
        return user

    path = avatar.path

    user.avatar_file_id = None

    db.delete(avatar)
    db.commit()

    file_storage.delete(path)

    db.refresh(user)

    return user