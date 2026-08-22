from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "8b9c0d1e2f33"
down_revision: Union[str, Sequence[str], None] = "7a8b9c0d1e22"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        """
        CREATE TYPE chat_type AS ENUM (
            'direct',
            'group'
        )
        """
    )

    op.create_table(
        "chats",
        sa.Column(
            "id",
            sa.Integer(),
            primary_key=True,
        ),
        sa.Column(
            "type",
            sa.Text(),
            nullable=False,
        ),
        sa.Column(
            "user_low_id",
            sa.Integer(),
            nullable=True,
        ),
        sa.Column(
            "user_high_id",
            sa.Integer(),
            nullable=True,
        ),
        sa.Column(
            "title",
            sa.String(length=100),
            nullable=True,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.ForeignKeyConstraint(
            ["user_low_id"],
            ["users.id"],
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["user_high_id"],
            ["users.id"],
            ondelete="CASCADE",
        ),
        sa.UniqueConstraint(
            "user_low_id",
            "user_high_id",
            name="uq_chats_direct_pair",
        ),
    )

    op.execute(
        """
        ALTER TABLE chats
        ALTER COLUMN type TYPE chat_type
        USING type::chat_type
        """
    )

    op.create_table(
        "chat_members",
        sa.Column(
            "id",
            sa.Integer(),
            primary_key=True,
        ),
        sa.Column(
            "chat_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "user_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            nullable=False,
            server_default=sa.true(),
        ),
        sa.Column(
            "joined_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.ForeignKeyConstraint(
            ["chat_id"],
            ["chats.id"],
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            ondelete="CASCADE",
        ),
        sa.UniqueConstraint(
            "chat_id",
            "user_id",
            name="uq_chat_members_chat_user",
        ),
    )

    op.create_index(
        "ix_chat_members_chat_id",
        "chat_members",
        ["chat_id"],
    )

    op.create_index(
        "ix_chat_members_user_id",
        "chat_members",
        ["user_id"],
    )

    op.create_table(
        "messages",
        sa.Column(
            "id",
            sa.Integer(),
            primary_key=True,
        ),
        sa.Column(
            "chat_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "sender_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "client_message_id",
            sa.String(length=64),
            nullable=False,
        ),
        sa.Column(
            "text",
            sa.String(length=4000),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "edited_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
        sa.Column(
            "is_deleted",
            sa.Boolean(),
            nullable=False,
            server_default=sa.false(),
        ),
        sa.ForeignKeyConstraint(
            ["chat_id"],
            ["chats.id"],
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["sender_id"],
            ["users.id"],
            ondelete="CASCADE",
        ),
        sa.UniqueConstraint(
            "sender_id",
            "client_message_id",
            name="uq_messages_sender_client_id",
        ),
    )

    op.create_index(
        "ix_messages_chat_id",
        "messages",
        ["chat_id"],
    )

    op.create_index(
        "ix_messages_sender_id",
        "messages",
        ["sender_id"],
    )

    op.create_index(
        "ix_messages_created_at",
        "messages",
        ["created_at"],
    )


def downgrade() -> None:
    op.drop_table("messages")

    op.drop_index(
        "ix_chat_members_user_id",
        table_name="chat_members",
    )

    op.drop_index(
        "ix_chat_members_chat_id",
        table_name="chat_members",
    )

    op.drop_table("chat_members")
    op.drop_table("chats")

    op.execute(
        "DROP TYPE IF EXISTS chat_type"
    )