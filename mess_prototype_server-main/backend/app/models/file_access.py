from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base

class FileAccess(Base):
    __tablename__ = 'file_access'

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True
    )

    file_id: Mapped[int] = mapped_column(
        ForeignKey('files.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey('users.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default='now()'
    )