from datetime import datetime, timezone

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.models.device_session import DeviceSession
from app.schemas.device_session import DeviceSessionCreate


def get_user_device_sessions(
    db: Session,
    user_id: int,
) -> list[DeviceSession]:
    return list(
        db.scalars(
            select(DeviceSession)
            .where(DeviceSession.user_id == user_id)
            .order_by(DeviceSession.last_seen.desc())
        )
    )


def create_or_update_device_session(
    db: Session,
    user_id: int,
    device_data: DeviceSessionCreate,
) -> DeviceSession:
    device = db.scalar(
        select(DeviceSession)
        .where(
            DeviceSession.user_id == user_id,
            DeviceSession.device_id == device_data.device_id,
        )
    )

    now = datetime.now(timezone.utc)

    if device is None:
        device = DeviceSession(
            user_id=user_id,
            device_id=device_data.device_id,
            device_name=device_data.device_name,
            platform=device_data.platform,
            created_at=now,
            last_seen=now,
            is_active=True,
        )

        db.add(device)

    else:
        device.device_name = device_data.device_name
        device.platform = device_data.platform
        device.last_seen = now
        device.is_active = True

    db.commit()
    db.refresh(device)

    return device


def update_device_last_seen(
    db: Session,
    session_id: str,
) -> DeviceSession | None:
    device = db.scalar(
        select(DeviceSession)
        .where(DeviceSession.session_id == session_id)
    )

    if device is None:
        return None

    device.last_seen = datetime.now(timezone.utc)
    device.is_active = True

    db.commit()
    db.refresh(device)

    return device


def deactivate_device_session(
    db: Session,
    user_id: int,
    session_id: str,
) -> bool:
    device = db.scalar(
        select(DeviceSession)
        .where(
            DeviceSession.session_id == session_id,
            DeviceSession.user_id == user_id,
        )
    )

    if device is None:
        return False

    device.is_active = False

    db.commit()

    return True


def delete_device_session(
    db: Session,
    user_id: int,
    session_id: str,
) -> bool:
    result = db.execute(
        delete(DeviceSession).where(
            DeviceSession.session_id == session_id,
            DeviceSession.user_id == user_id,
        )
    )

    db.commit()

    return result.rowcount > 0