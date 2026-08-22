from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from jose import JWTError
from sqlalchemy import select

from app.core.security import decode_access_token
from app.database.session import SessionLocal
from app.models.user import (
    User,
    UserPresence,
    UserStatus,
)
from app.models.device_session import DeviceSession
from app.models.chat import Message, ChatMember

from app.services.chat import get_chat_for_user

from app.realtime.manager import manager
from app.realtime.user_events import (
    broadcast_presence,
    broadcast_status,
)


router = APIRouter(tags=['Realtime'])


def _get_token(websocket: WebSocket) -> str | None:
    authorization = websocket.headers.get('authorization')
    if not authorization:
        return None

    scheme, _, token = authorization.partition(' ')
    if scheme.lower() != 'bearer' or not token:
        return None

    return token


@router.websocket('/messenger-ws')
async def messenger_websocket(websocket: WebSocket) -> None:
    token = _get_token(websocket)
    if not token:
        await websocket.close(code=1008, reason='Authorization required')
        return

    try:
        user_id = decode_access_token(token)

        device_id = websocket.query_params.get(
            'device_id'
        )

        if not device_id:
            await websocket.close(
                code=1008,
                reason='Device ID required',
            )
            return
    except (JWTError, ValueError, TypeError):
        await websocket.close(code=1008, reason='Invalid or expired token')
        return

    with SessionLocal() as db:
        user = db.scalar(select(User).where(User.id == user_id))
        if user is None or not user.is_active:
            await websocket.close(code=1008, reason='User is not available')
            return

    with SessionLocal() as db:
        device_session = db.scalar(
            select(DeviceSession)
            .where(
                DeviceSession.user_id == user_id,
                DeviceSession.device_id == device_id,
                DeviceSession.is_active.is_(True),
            )
        )

        if device_session is None:
            await websocket.close(
                code=1008,
                reason='Device session not found',
            )
            return

        session_id = device_session.session_id

        device_session.last_seen = datetime.now(
            timezone.utc
        )

        db.commit()
    
    await websocket.accept()

    with SessionLocal() as db:
        user = db.scalar(
            select(User).where(
                User.id == user_id
            )
        )

        if user is None:
            await websocket.close(
                code=1008,
                reason="User not found",
            )
            return

    first_connection = manager.connect(
        user_id,
        session_id,
        websocket,
    )

    if first_connection:
        with SessionLocal() as db:
            user = db.scalar(
                select(User).where(
                    User.id == user_id
                )
            )

            if user is not None:
                user.presence = UserPresence.ONLINE
                user.last_seen = None

                db.commit()
                db.refresh(user)

                await broadcast_presence(
                    db,
                    user,
                )

    await websocket.send_json({
        'type': 'connection.ready',
        'data': {
            'user_id': user_id,
            'session_id': session_id,
            'device_id': device_id,
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
                    status_value = UserStatus(
                        requested_status
                    )
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
                    db_user = db.scalar(
                        select(User).where(
                            User.id == user_id
                        )
                    )

                    if db_user is None:
                        continue

                    db_user.status = status_value

                    db.commit()
                    db.refresh(db_user)

                    await broadcast_status(
                        db,
                        db_user,
                    )

                continue

            if message_type == "message.send":
                chat_id = data.get("chat_id")
                client_message_id = data.get(
                    "client_message_id"
                )
                text = data.get("text")

                if not isinstance(chat_id, int):
                    await websocket.send_json({
                        "type": "error",
                        "data": {
                            "code": "invalid_chat_id",
                            "message": "Invalid chat id",
                        },
                    })
                    continue

                if (
                    not isinstance(client_message_id, str)
                    or not client_message_id
                    or len(client_message_id) > 64
                ):
                    await websocket.send_json({
                        "type": "error",
                        "data": {
                            "code": "invalid_client_message_id",
                            "message": "Invalid client message id",
                        },
                    })
                    continue

                if not isinstance(text, str):
                    await websocket.send_json({
                        "type": "error",
                        "data": {
                            "code": "invalid_message",
                            "message": "Invalid message text",
                        },
                    })
                    continue

                text = text.strip()

                if not text:
                    continue

                if len(text) > 4000:
                    await websocket.send_json({
                        "type": "error",
                        "data": {
                            "code": "message_too_long",
                            "message": "Message is too long",
                        },
                    })
                    continue

                with SessionLocal() as db:
                    chat = get_chat_for_user(
                        db=db,
                        chat_id=chat_id,
                        user_id=user_id,
                    )

                    if chat is None:
                        await websocket.send_json({
                            "type": "error",
                            "data": {
                                "code": "chat_not_found",
                                "message": "Chat not found",
                            },
                        })
                        continue

                    existing = db.scalar(
                        select(Message).where(
                            Message.sender_id == user_id,
                            Message.client_message_id
                            == client_message_id,
                        )
                    )

                    if existing is not None:
                        message_obj = existing
                    else:
                        message_obj = Message(
                            chat_id=chat_id,
                            sender_id=user_id,
                            client_message_id=client_message_id,
                            text=text,
                        )

                        db.add(message_obj)

                        chat.updated_at = (
                            datetime.now(timezone.utc)
                        )

                        db.commit()
                        db.refresh(message_obj)

                    members = db.scalars(
                        select(ChatMember).where(
                            ChatMember.chat_id == chat_id,
                            ChatMember.is_active.is_(True),
                        )
                    ).all()

                    member_ids = [
                        member.user_id
                        for member in members
                    ]

                event = {
                    "type": "message.created",
                    "data": {
                        "id": message_obj.id,
                        "chat_id": message_obj.chat_id,
                        "sender_id": message_obj.sender_id,
                        "client_message_id":
                            message_obj.client_message_id,
                        "text": message_obj.text,
                        "created_at":
                            message_obj.created_at.isoformat(),
                        "edited_at": None,
                        "is_deleted": False,
                    },
                }

                for member_id in member_ids:
                    await manager.send_to_user(
                        member_id,
                        event,
                    )

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
        became_offline = manager.disconnect(user_id, session_id)

        if became_offline:
            with SessionLocal() as db:
                user = db.scalar(
                    select(User).where(
                        User.id == user_id
                    )
                )

                if user is not None:
                    user.presence = UserPresence.OFFLINE
                    user.last_seen = datetime.now(
                        timezone.utc
                    )

                    db.commit()
                    db.refresh(user)

                    await broadcast_presence(
                        db,
                        user,
                    )

        with SessionLocal() as db:
            session = db.scalar(
                select(DeviceSession)
                .where(
                    DeviceSession.session_id == session_id
                )
            )

            if session is not None:
                session.last_seen = datetime.now(
                    timezone.utc
                )
                db.commit()
