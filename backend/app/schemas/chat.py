from datetime import datetime

from pydantic import BaseModel


class ChatUser(BaseModel):
    id: int
    username: str
    first_name: str | None
    avatar_file_id: str | None
    presence: str
    status: str


class MessageResponse(BaseModel):
    id: int
    chat_id: int
    sender_id: int
    client_message_id: str
    text: str
    created_at: datetime
    edited_at: datetime | None
    is_deleted: bool


class ChatResponse(BaseModel):
    id: int
    type: str
    title: str | None
    other_user: ChatUser | None
    created_at: datetime
    updated_at: datetime
    last_message: MessageResponse | None


class ChatSyncResponse(BaseModel):
    chats: list[ChatResponse]


class CreateDirectChatRequest(BaseModel):
    user_id: int


class MessageHistoryResponse(BaseModel):
    messages: list[MessageResponse]