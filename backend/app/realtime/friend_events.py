from typing import Any

from app.models.friendship import Friendship
from app.models.user import User
from app.services.friend import _friend_user


def friend_requested_event(
    friendship: Friendship,
    requester: User,
) -> dict[str, Any]:
    return {
        "type": "friend.requested",
        "data": {
            "friendship_id": friendship.id,
            "user": _friend_user(requester).model_dump(
                mode="json"
            ),
            "created_at": friendship.created_at.isoformat(),
        },
    }


def friend_updated_event(
    friendship: Friendship,
    friend_user: User,
) -> dict[str, Any]:
    return {
        "type": "friend.updated",
        "data": {
            "friendship_id": friendship.id,
            "user": _friend_user(friend_user).model_dump(
                mode="json"
            ),
            "status": friendship.status.value,
        },
    }


def friend_removed_event(
    friendship_id: int,
    friend_user_id: int,
) -> dict[str, Any]:
    return {
        "type": "friend.removed",
        "data": {
            "friendship_id": friendship_id,
            "user_id": friend_user_id,
        },
    }