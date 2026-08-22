"""create device sessions

Revision ID: 6d7e8f9a0b11
Revises: 45d22debc949
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "6d7e8f9a0b11"
down_revision: Union[str, Sequence[str], None] = "45d22debc949"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "device_sessions",
        sa.Column(
            "session_id",
            sa.String(length=36),
            nullable=False,
        ),
        sa.Column(
            "user_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "device_id",
            sa.String(length=128),
            nullable=False,
        ),
        sa.Column(
            "device_name",
            sa.String(length=100),
            nullable=False,
        ),
        sa.Column(
            "platform",
            sa.String(length=30),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "last_seen",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            nullable=False,
            server_default=sa.true(),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("session_id"),
        sa.UniqueConstraint(
            "user_id",
            "device_id",
            name="uq_device_sessions_user_device",
        ),
    )

    op.create_index(
        op.f("ix_device_sessions_user_id"),
        "device_sessions",
        ["user_id"],
        unique=False,
    )

    op.create_index(
        op.f("ix_device_sessions_last_seen"),
        "device_sessions",
        ["last_seen"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(
        op.f("ix_device_sessions_last_seen"),
        table_name="device_sessions",
    )

    op.drop_index(
        op.f("ix_device_sessions_user_id"),
        table_name="device_sessions",
    )

    op.drop_table("device_sessions")