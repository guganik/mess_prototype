from __future__ import annotations

from datetime import datetime
from typing import Any

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models.friendship import (
    Friendship,
    FriendshipStatus,
)
from app.models.user import User
from app.realtime.manager import manager


def _iso(value: datetime | None) -> str | None:
    return value.isoformat() if value else None


def public_user_data(
    user: User,
) -> dict[str, Any]:
    return {
        "user_id": user.id,
        "username": user.username,
        "first_name": user.first_name,
        "avatar_file_id": (
            user.avatar_file.file_id
            if user.avatar_file is not None
            else None
        ),
        "status": user.status.value,
        "presence": user.presence.value,
        "last_seen": _iso(user.last_seen),
        "is_active": user.is_active,
    }


def own_profile_event(
    user: User,
) -> dict[str, Any]:
    return {
        "type": "profile.updated",
        "data": {
            "user_id": user.id,
            "username": user.username,
            "first_name": user.first_name,
            "email": user.email,
            "phone": user.phone,
            "avatar_file_id": (
                user.avatar_file.file_id
                if user.avatar_file is not None
                else None
            ),
            "status": user.status.value,
            "presence": user.presence.value,
            "last_seen": _iso(user.last_seen),
            "is_active": user.is_active,
        },
    }


def public_profile_event(
    user: User,
) -> dict[str, Any]:
    return {
        "type": "profile.updated",
        "data": public_user_data(user),
    }


def presence_event(
    user: User,
) -> dict[str, Any]:
    return {
        "type": "presence.updated",
        "data": {
            "user_id": user.id,
            "presence": user.presence.value,
            "last_seen": _iso(user.last_seen),
        },
    }


def status_event(
    user: User,
) -> dict[str, Any]:
    return {
        "type": "status.updated",
        "data": {
            "user_id": user.id,
            "status": user.status.value,
        },
    }


def avatar_event(
    user: User,
) -> dict[str, Any]:
    return {
        "type": "avatar.updated",
        "data": {
            "user_id": user.id,
            "avatar_file_id": (
                user.avatar_file.file_id
                if user.avatar_file is not None
                else None
            ),
        },
    }


def get_friend_ids(
    db: Session,
    user_id: int,
) -> list[int]:
    friendships = db.scalars(
        select(Friendship).where(
            Friendship.status
            == FriendshipStatus.ACCEPTED,
            or_(
                Friendship.requester_id == user_id,
                Friendship.addressee_id == user_id,
            ),
        )
    ).all()

    result: list[int] = []

    for friendship in friendships:
        friend_id = (
            friendship.addressee_id
            if friendship.requester_id == user_id
            else friendship.requester_id
        )

        result.append(friend_id)

    return result


async def broadcast_presence(
    db: Session,
    user: User,
) -> None:
    event = presence_event(user)

    await manager.send_to_user(
        user.id,
        event,
    )

    for friend_id in get_friend_ids(
        db,
        user.id,
    ):
        await manager.send_to_user(
            friend_id,
            event,
        )


async def broadcast_status(
    db: Session,
    user: User,
) -> None:
    event = status_event(user)

    await manager.send_to_user(
        user.id,
        event,
    )

    for friend_id in get_friend_ids(
        db,
        user.id,
    ):
        await manager.send_to_user(
            friend_id,
            event,
        )


async def broadcast_profile(
    db: Session,
    user: User,
    excluded_session_id: str | None = None,
) -> None:
    own_event = own_profile_event(user)
    public_event = public_profile_event(user)

    if excluded_session_id is None:
        await manager.send_to_user(
            user.id,
            own_event,
        )
    else:
        await manager.send_to_user_except(
            user.id,
            excluded_session_id,
            own_event,
        )

    for friend_id in get_friend_ids(
        db,
        user.id,
    ):
        await manager.send_to_user(
            friend_id,
            public_event,
        )


async def broadcast_avatar(
    db: Session,
    user: User,
    excluded_session_id: str | None = None,
) -> None:
    event = avatar_event(user)

    if excluded_session_id is None:
        await manager.send_to_user(
            user.id,
            event,
        )
    else:
        await manager.send_to_user_except(
            user.id,
            excluded_session_id,
            event,
        )

    for friend_id in get_friend_ids(
        db,
        user.id,
    ):
        await manager.send_to_user(
            friend_id,
            event,
        )