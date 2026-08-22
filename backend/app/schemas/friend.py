from datetime import datetime

from pydantic import BaseModel


class FriendUser(BaseModel):
    id: int
    username: str
    first_name: str | None
    avatar_file_id: str | None
    status: str
    presence: str
    last_seen: datetime | None


class FriendResponse(BaseModel):
    friendship_id: int
    user: FriendUser
    created_at: datetime


class FriendRequestResponse(BaseModel):
    friendship_id: int
    user: FriendUser
    created_at: datetime


class FriendSyncResponse(BaseModel):
    friends: list[FriendResponse]
    incoming_requests: list[FriendRequestResponse]
    outgoing_requests: list[FriendRequestResponse]


class CreateFriendRequest(BaseModel):
    user_id: int

class FriendSearchUser(BaseModel):
    id: int
    username: str
    first_name: str | None
    avatar_file_id: str | None
    status: str
    presence: str
    last_seen: datetime | None
    is_active: bool
    relation: str