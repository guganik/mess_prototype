from datetime import datetime
import enum

from sqlalchemy import DateTime, ForeignKey, Integer, String, Boolean, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.user import User

class FileAccessType(str, enum.Enum):
    PRIVATE = 'private'
    SHARED = 'shared'
    PUBLIC = 'public'

class File(Base):
    __tablename__ = 'files'

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True
    )

    file_id: Mapped[str] = mapped_column(
        String(36),
        unique=True,
        nullable=False,
        index=True
    )

    path: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    owner_id: Mapped[int] = mapped_column(
        ForeignKey('users.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    owner: Mapped['User'] = relationship(
        'User',
        foreign_keys=[owner_id]
    )

    access_type: Mapped[FileAccessType] = mapped_column(
        Enum(FileAccessType, name='file_access_type'),
        nullable=False,
        default=FileAccessType.PRIVATE
    )

    allow_forward: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True
    )

    stored_name: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        unique=True
    )

    original_name: Mapped[str] = mapped_column(
        String(255),
        nullable=False
    )

    mime_type: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )

    size: Mapped[int] = mapped_column(
        Integer,
        nullable=False
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default='now()'
    )