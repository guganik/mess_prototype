from __future__ import annotations

from collections import defaultdict
from typing import Any

from fastapi import WebSocket


class ConnectionManager:
    def __init__(self) -> None:
        self._connections: dict[int, dict[str, WebSocket]] = defaultdict(dict)

    def connect(
        self,
        user_id: int,
        session_id: str,
        websocket: WebSocket,
    ) -> bool:
        was_offline = not self._connections[user_id]

        self._connections[user_id][session_id] = websocket

        return was_offline

    def disconnect(
        self,
        user_id: int,
        session_id: str,
    ) -> bool:
        connections = self._connections.get(user_id)

        if not connections:
            return True

        connections.pop(session_id, None)

        if not connections:
            self._connections.pop(user_id, None)
            return True

        return False

    def is_online(self, user_id: int) -> bool:
        return bool(
            self._connections.get(user_id)
        )

    def is_device_connected(
        self,
        user_id: int,
        session_id: str,
    ) -> bool:
        return session_id in self._connections.get(
            user_id,
            {},
        )

    async def send_to_user(
        self,
        user_id: int,
        message: dict[str, Any],
    ) -> None:
        connections = self._connections.get(user_id)

        if not connections:
            return

        dead_sessions: list[str] = []

        for session_id, websocket in list(
            connections.items()
        ):
            try:
                await websocket.send_json(message)
            except Exception:
                dead_sessions.append(session_id)

        for session_id in dead_sessions:
            self.disconnect(
                user_id,
                session_id,
            )

    async def send_to_device(
        self,
        user_id: int,
        session_id: str,
        message: dict[str, Any],
    ) -> None:
        websocket = self._connections.get(
            user_id,
            {},
        ).get(session_id)

        if websocket is None:
            return

        try:
            await websocket.send_json(message)
        except Exception:
            self.disconnect(
                user_id,
                session_id,
            )

    async def broadcast(
        self,
        message: dict[str, Any],
    ) -> None:
        sockets = [
            (user_id, session_id, websocket)
            for user_id, connections
            in self._connections.items()
            for session_id, websocket
            in connections.items()
        ]

        dead_connections: list[
            tuple[int, str]
        ] = []

        for user_id, session_id, websocket in sockets:
            try:
                await websocket.send_json(message)
            except Exception:
                dead_connections.append(
                    (
                        user_id,
                        session_id,
                    )
                )

        for user_id, session_id in dead_connections:
            self.disconnect(
                user_id,
                session_id,
            )

    async def send_to_user_except(
        self,
        user_id: int,
        excluded_session_id: str | None,
        message: dict[str, Any],
    ) -> None:
        connections = self._connections.get(user_id)

        if not connections:
            return

        dead_sessions: list[str] = []

        for session_id, websocket in list(connections.items()):
            if session_id == excluded_session_id:
                continue

            try:
                await websocket.send_json(message)
            except Exception:
                dead_sessions.append(session_id)

        for session_id in dead_sessions:
            self.disconnect(
                user_id,
                session_id,
            )


manager = ConnectionManager()