from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    status,
)
from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.database.session import get_db
from app.models.user import User
from app.schemas.chat import (
    ChatSyncResponse,
    CreateDirectChatRequest,
    MessageHistoryResponse,
    MessageResponse,
)
from app.services.chat import (
    create_direct_chat,
    get_messages,
    sync_chats,
)


router = APIRouter(
    prefix="/chats",
    tags=["Chats"],
)


@router.get(
    "/sync",
    response_model=ChatSyncResponse,
)
def sync_my_chats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return sync_chats(
        db=db,
        user_id=current_user.id,
    )


@router.post(
    "/direct",
)
def create_my_direct_chat(
    request_data: CreateDirectChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        chat = create_direct_chat(
            db=db,
            user_id=current_user.id,
            other_user_id=request_data.user_id,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    return {
        "chat_id": chat.id,
    }


@router.get(
    "/{chat_id}/messages",
    response_model=MessageHistoryResponse,
)
def get_chat_messages(
    chat_id: int,
    limit: int = Query(
        default=50,
        ge=1,
        le=100,
    ),
    before_id: int | None = Query(
        default=None,
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        messages = get_messages(
            db=db,
            chat_id=chat_id,
            user_id=current_user.id,
            limit=limit,
            before_id=before_id,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        )

    return MessageHistoryResponse(
        messages=[
            MessageResponse(
                id=message.id,
                chat_id=message.chat_id,
                sender_id=message.sender_id,
                client_message_id=message.client_message_id,
                text=message.text,
                created_at=message.created_at,
                edited_at=message.edited_at,
                is_deleted=message.is_deleted,
            )
            for message in messages
        ]
    )