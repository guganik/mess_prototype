import enum
from datetime import datetime

from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.file import File


class UserStatus(str, enum.Enum):
    ONLINE = 'online'
    AWAY = 'away'
    DO_NOT_DISTURB = 'do_not_disturb'
    OFFLINE = 'offline'

class UserPresence(str, enum.Enum):
    ONLINE = 'online'
    OFFLINE = 'offline'

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True
    )

    username: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False,
        index=True
    )

    first_name: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True
    )

    email: Mapped[str | None] = mapped_column(
        String(255),
        unique=True,
        nullable=True,
        index=True
    )

    phone: Mapped[str | None] = mapped_column(
        String(30),
        unique=True,
        nullable=True,
        index=True
    )

    avatar_file_id: Mapped[int | None] = mapped_column(
        ForeignKey('files.id', ondelete='SET NULL'),
        nullable=True,
        index=True
    )

    avatar_file: Mapped['File | None'] = relationship(
        'File',
        foreign_keys=[avatar_file_id],
        lazy='selectin'
    )

    status: Mapped[UserStatus] = mapped_column(
        Enum(UserStatus, name="user_status"),
        nullable=False,
        default=UserStatus.OFFLINE
    )

    presence: Mapped[UserPresence] = mapped_column(
        Enum(UserPresence, name="user_presence"),
        nullable=False,
        default=UserPresence.OFFLINE
    )

    last_seen: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )

    password_hash: Mapped[str] = mapped_column(
        String(255),
        nullable=False
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default="now()"
    )