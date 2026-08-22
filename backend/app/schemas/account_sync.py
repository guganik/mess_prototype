from pydantic import BaseModel

from app.schemas.user import UserResponse
from app.schemas.friend import (
    FriendResponse,
    FriendRequestResponse,
)
from app.schemas.chat import ChatResponse


class AccountSyncResponse(BaseModel):
    user: UserResponse

    friends: list[FriendResponse]

    incoming_requests: list[FriendRequestResponse]

    outgoing_requests: list[FriendRequestResponse]

    chats: list[ChatResponse]