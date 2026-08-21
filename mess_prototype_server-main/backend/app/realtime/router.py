from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from jose import JWTError
from sqlalchemy import select

from app.core.security import decode_access_token
from app.database.session import SessionLocal
from app.models.user import User, UserPresence, UserStatus
from app.realtime.manager import manager

router = APIRouter(tags=['Realtime'])


def _get_token(websocket: WebSocket) -> str | None:
    authorization = websocket.headers.get('authorization')
    if not authorization:
        return None

    scheme, _, token = authorization.partition(' ')
    if scheme.lower() != 'bearer' or not token:
        return None

    return token


def _set_presence(user_id: int, presence: UserPresence) -> None:
    with SessionLocal() as db:
        user = db.scalar(select(User).where(User.id == user_id))
        if user is None:
            return

        user.presence = presence
        if presence == UserPresence.OFFLINE:
            user.last_seen = datetime.now(timezone.utc)

        db.commit()


@router.websocket('/messenger-ws')
async def messenger_websocket(websocket: WebSocket) -> None:
    token = _get_token(websocket)
    if not token:
        await websocket.close(code=1008, reason='Authorization required')
        return

    try:
        user_id = decode_access_token(token)
    except (JWTError, ValueError, TypeError):
        await websocket.close(code=1008, reason='Invalid or expired token')
        return

    with SessionLocal() as db:
        user = db.scalar(select(User).where(User.id == user_id))
        if user is None or not user.is_active:
            await websocket.close(code=1008, reason='User is not available')
            return

    await websocket.accept()

    first_connection = manager.connect(user_id, websocket)
    if first_connection:
        _set_presence(user_id, UserPresence.ONLINE)
        await manager.broadcast({
            'type': 'presence.updated',
            'data': {
                'user_id': user_id,
                'presence': UserPresence.ONLINE.value,
                'last_seen': None,
            },
        })

    await websocket.send_json({
        'type': 'connection.ready',
        'data': {
            'user_id': user_id,
        },
    })

    try:
        while True:
            message: dict[str, Any] = await websocket.receive_json()
            message_type = message.get('type')

            if message_type == 'ping':
                await websocket.send_json({
                    'type': 'pong',
                    'data': {},
                })
                continue

            data = message.get('data')
            if not isinstance(data, dict):
                data = {}

            if message_type == 'status.set':
                requested_status = data.get('status')
                try:
                    status_value = UserStatus(requested_status)
                except (TypeError, ValueError):
                    await websocket.send_json({
                        'type': 'error',
                        'data': {
                            'code': 'invalid_status',
                            'message': 'Invalid user status',
                        },
                    })
                    continue

                with SessionLocal() as db:
                    db_user = db.scalar(select(User).where(User.id == user_id))
                    if db_user is not None:
                        db_user.status = status_value
                        db.commit()

                await manager.broadcast({
                    'type': 'status.updated',
                    'data': {
                        'user_id': user_id,
                        'status': status_value.value,
                    },
                })
                continue

            await websocket.send_json({
                'type': 'ack',
                'data': {
                    'event': message_type,
                },
            })
    except WebSocketDisconnect:
        pass
    finally:
        became_offline = manager.disconnect(user_id, websocket)

        if became_offline:
            _set_presence(user_id, UserPresence.OFFLINE)
            await manager.broadcast({
                'type': 'presence.updated',
                'data': {
                    'user_id': user_id,
                    'presence': UserPresence.OFFLINE.value,
                    'last_seen': datetime.now(timezone.utc).isoformat(),
                },
            })
