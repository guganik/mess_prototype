from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.chat import (
    Chat,
    ChatMember,
    ChatType,
    Message,
)
from app.models.user import User
from app.schemas.chat import (
    ChatResponse,
    ChatSyncResponse,
    ChatUser,
    MessageResponse,
)


def _user_schema(user: User) -> ChatUser:
    return ChatUser(
        id=user.id,
        username=user.username,
        first_name=user.first_name,
        avatar_file_id=(
            user.avatar_file.file_id
            if user.avatar_file
            else None
        ),
        presence=user.presence.value,
        status=user.status.value,
    )


def _message_schema(
    message: Message,
) -> MessageResponse:
    return MessageResponse(
        id=message.id,
        chat_id=message.chat_id,
        sender_id=message.sender_id,
        client_message_id=message.client_message_id,
        text=message.text,
        created_at=message.created_at,
        edited_at=message.edited_at,
        is_deleted=message.is_deleted,
    )


def _last_message(
    db: Session,
    chat_id: int,
) -> Message | None:
    return db.scalar(
        select(Message)
        .where(Message.chat_id == chat_id)
        .order_by(Message.id.desc())
        .limit(1)
    )


def get_chat_for_user(
    db: Session,
    chat_id: int,
    user_id: int,
) -> Chat | None:
    return db.scalar(
        select(Chat)
        .join(
            ChatMember,
            ChatMember.chat_id == Chat.id,
        )
        .where(
            Chat.id == chat_id,
            ChatMember.user_id == user_id,
            ChatMember.is_active.is_(True),
        )
    )


def get_direct_chat(
    db: Session,
    user_a: int,
    user_b: int,
) -> Chat | None:
    low_id = min(user_a, user_b)
    high_id = max(user_a, user_b)

    return db.scalar(
        select(Chat).where(
            Chat.type == ChatType.DIRECT,
            Chat.user_low_id == low_id,
            Chat.user_high_id == high_id,
        )
    )


def create_direct_chat(
    db: Session,
    user_id: int,
    other_user_id: int,
) -> Chat:
    if user_id == other_user_id:
        raise ValueError(
            "Cannot create chat with yourself"
        )

    other_user = db.scalar(
        select(User).where(User.id == other_user_id)
    )

    if other_user is None or not other_user.is_active:
        raise ValueError(
            "User not found"
        )

    existing = get_direct_chat(
        db=db,
        user_a=user_id,
        user_b=other_user_id,
    )

    if existing is not None:
        return existing

    low_id = min(user_id, other_user_id)
    high_id = max(user_id, other_user_id)

    chat = Chat(
        type=ChatType.DIRECT,
        user_low_id=low_id,
        user_high_id=high_id,
    )

    db.add(chat)
    db.flush()

    db.add_all(
        [
            ChatMember(
                chat_id=chat.id,
                user_id=user_id,
            ),
            ChatMember(
                chat_id=chat.id,
                user_id=other_user_id,
            ),
        ]
    )

    db.commit()
    db.refresh(chat)

    return chat


def sync_chats(
    db: Session,
    user_id: int,
) -> ChatSyncResponse:
    chats = db.scalars(
        select(Chat)
        .join(
            ChatMember,
            ChatMember.chat_id == Chat.id,
        )
        .where(
            ChatMember.user_id == user_id,
            ChatMember.is_active.is_(True),
        )
        .order_by(Chat.updated_at.desc())
    ).all()

    result = []

    for chat in chats:
        other_user = None

        if (
            chat.type == ChatType.DIRECT
            and chat.user_low_id is not None
            and chat.user_high_id is not None
        ):
            other_user_id = (
                chat.user_high_id
                if chat.user_low_id == user_id
                else chat.user_low_id
            )

            other_user = db.scalar(
                select(User).where(
                    User.id == other_user_id
                )
            )

        last_message = _last_message(
            db,
            chat.id,
        )

        result.append(
            ChatResponse(
                id=chat.id,
                type=chat.type.value,
                title=chat.title,
                other_user=(
                    _user_schema(other_user)
                    if other_user
                    else None
                ),
                created_at=chat.created_at,
                updated_at=chat.updated_at,
                last_message=(
                    _message_schema(last_message)
                    if last_message
                    else None
                ),
            )
        )

    return ChatSyncResponse(
        chats=result,
    )


def get_messages(
    db: Session,
    chat_id: int,
    user_id: int,
    limit: int = 50,
    before_id: int | None = None,
) -> list[Message]:
    chat = get_chat_for_user(
        db,
        chat_id,
        user_id,
    )

    if chat is None:
        raise ValueError(
            "Chat not found"
        )

    query = (
        select(Message)
        .where(Message.chat_id == chat_id)
        .order_by(Message.id.desc())
        .limit(min(max(limit, 1), 100))
    )

    if before_id is not None:
        query = query.where(
            Message.id < before_id
        )

    messages = list(
        db.scalars(query)
    )

    messages.reverse()

    return messages