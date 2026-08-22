from datetime import datetime
from typing import Any

from app.models.user import User


def _datetime_to_iso(
    value: datetime | None,
) -> str | None:
    if value is None:
        return None

    return value.isoformat()


def profile_updated_event(user: User) -> dict[str, Any]:
    return {
        'type': 'profile.updated',
        'data': {
            'user_id': user.id,
            'username': user.username,
            'first_name': user.first_name,
            'email': user.email,
            'phone': user.phone,
            'status': user.status.value,
            'presence': user.presence.value,
            'last_seen': _datetime_to_iso(user.last_seen),
            'is_active': user.is_active,
        },
    }


def avatar_updated_event(user: User) -> dict[str, Any]:
    avatar_file_id = None

    if user.avatar_file is not None:
        avatar_file_id = user.avatar_file.file_id

    return {
        'type': 'avatar.updated',
        'data': {
            'user_id': user.id,
            'avatar_file_id': avatar_file_id,
        },
    }