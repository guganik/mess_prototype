from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "7a8b9c0d1e22"
down_revision: Union[str, Sequence[str], None] = "6d7e8f9a0b11"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        "DROP TABLE IF EXISTS friendships CASCADE"
    )

    op.execute(
        "DROP TYPE IF EXISTS friendship_status CASCADE"
    )

    op.create_table(
        "friendships",
        sa.Column(
            "id",
            sa.Integer(),
            primary_key=True,
        ),
        sa.Column(
            "requester_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "addressee_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "user_low_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "user_high_id",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "status",
            sa.Enum(
                "pending",
                "accepted",
                "rejected",
                "blocked",
                name="friendship_status_v2",
            ),
            nullable=False,
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
            ["requester_id"],
            ["users.id"],
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["addressee_id"],
            ["users.id"],
            ondelete="CASCADE",
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
            name="uq_friendships_user_pair",
        ),
        sa.CheckConstraint(
            "requester_id != addressee_id",
            name="ck_friendships_different_users",
        ),
    )


def downgrade() -> None:
    op.drop_table("friendships")
    op.execute(
        "DROP TYPE IF EXISTS friendship_status_v2 CASCADE"
    )