from __future__ import annotations

from collections import defaultdict
from typing import Any

from fastapi import WebSocket


class ConnectionManager:
    def __init__(self) -> None:
        self._connections: dict[int, set[WebSocket]] = defaultdict(set)

    def connect(self, user_id: int, websocket: WebSocket) -> bool:
        was_offline = not self._connections[user_id]
        self._connections[user_id].add(websocket)
        return was_offline

    def disconnect(self, user_id: int, websocket: WebSocket) -> bool:
        connections = self._connections.get(user_id)
        if not connections:
            return True

        connections.discard(websocket)

        if not connections:
            self._connections.pop(user_id, None)
            return True

        return False

    def is_online(self, user_id: int) -> bool:
        return bool(self._connections.get(user_id))

    async def send_to_user(self, user_id: int, message: dict[str, Any]) -> None:
        dead_connections: list[WebSocket] = []

        for websocket in list(self._connections.get(user_id, ())):
            try:
                await websocket.send_json(message)
            except Exception:
                dead_connections.append(websocket)

        if dead_connections:
            connections = self._connections.get(user_id)
            if connections is not None:
                for websocket in dead_connections:
                    connections.discard(websocket)
                if not connections:
                    self._connections.pop(user_id, None)

    async def broadcast(self, message: dict[str, Any]) -> None:
        sockets = [
            websocket
            for connections in self._connections.values()
            for websocket in connections
        ]
        dead_connections: list[tuple[int, WebSocket]] = []

        for websocket in sockets:
            try:
                await websocket.send_json(message)
            except Exception:
                for user_id, connections in self._connections.items():
                    if websocket in connections:
                        dead_connections.append((user_id, websocket))
                        break

        for user_id, websocket in dead_connections:
            self.disconnect(user_id, websocket)


manager = ConnectionManager()
