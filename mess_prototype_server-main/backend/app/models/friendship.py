import enum

from sqlalchemy import Column, Integer, Enum, DateTime, ForeignKey

from sqlalchemy.orm import Mapped, mapped_column

from datetime import datetime, timezone

from app.database.base import Base

class FriendshipStatus(str, enum.Enum):
    PENDING = 'panding'
    ACCEPTED = 'accepted'
    REJECTED = 'rejected'
    BLOCKED = 'blocked'
    REMOVED = 'removed'

class Friendship(Base):
    __tablename__ = 'friendships'

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )

    target_user_id: Mapped[int] = mapped_column(
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )

    status: Mapped[FriendshipStatus] = mapped_column(
        Enum(FriendshipStatus, name='friendship_status'),
        nullable=False,
        default=FriendshipStatus.PENDING
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc)
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc)
    )