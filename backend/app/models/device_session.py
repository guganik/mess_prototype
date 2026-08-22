import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base


class DeviceSession(Base):
    __tablename__ = "device_sessions"

    __table_args__ = (
        UniqueConstraint(
            "user_id",
            "device_id",
            name="uq_device_sessions_user_device",
        ),
    )

    session_id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    device_id: Mapped[str] = mapped_column(
        String(128),
        nullable=False,
    )

    device_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    platform: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default="now()",
    )

    last_seen: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default="now()",
        index=True,
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )

    user = relationship(
        "User",
        back_populates="device_sessions",
    )