from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session

from sqlalchemy import select


from app.auth.dependencies import get_current_user

from app.database.session import get_db

from app.models.user import User
from app.models.device_session import DeviceSession

from app.realtime.user_events import (
    broadcast_profile,
    broadcast_avatar,
)

from app.services.user import update_user, update_avatar, delete_avatar
from app.services.device_session import (
    create_or_update_device_session,
    deactivate_device_session,
    delete_device_session,
    get_user_device_sessions,
)
from app.services.friend import get_friend_sync
from app.services.chat import sync_chats

from app.schemas.user import UserResponse, UserUpdate, AvatarUpdate
from app.schemas.device_session import (
    DeviceSessionCreate,
    DeviceSessionResponse,
)
from app.schemas.account_sync import AccountSyncResponse


router = APIRouter(
    prefix='/users',
    tags=['Users']
)

@router.get('/me', response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.patch(
    '/me',
    response_model=UserResponse,
)
async def update_me(
    request: Request,
    user_data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        user = update_user(
            db=db,
            user=current_user,
            user_data=user_data,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(exc),
        )

    device_id = request.headers.get(
        'X-Device-ID'
    )

    excluded_session_id = None

    if device_id:
        device_session = db.scalar(
            select(DeviceSession).where(
                DeviceSession.user_id
                == current_user.id,
                DeviceSession.device_id
                == device_id,
                DeviceSession.is_active.is_(True),
            )
        )

        if device_session is not None:
            excluded_session_id = (
                device_session.session_id
            )

    await broadcast_profile(
        db=db,
        user=user,
        excluded_session_id=excluded_session_id,
    )

    return user

@router.patch(
    '/me/avatar',
    response_model=UserResponse,
)
async def update_my_avatar(
    request: Request,
    avatar_data: AvatarUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        user = update_avatar(
            db=db,
            user=current_user,
            file_id=avatar_data.file_id,
        )
    except ValueError as exc:
        if str(exc) == 'File not found':
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(exc),
            )

        if str(exc) == 'Access denied':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=str(exc),
            )

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    device_id = request.headers.get(
        'X-Device-ID'
    )

    excluded_session_id = None

    if device_id:
        device_session = db.scalar(
            select(DeviceSession).where(
                DeviceSession.user_id
                == current_user.id,
                DeviceSession.device_id
                == device_id,
                DeviceSession.is_active.is_(True),
            )
        )

        if device_session is not None:
            excluded_session_id = (
                device_session.session_id
            )

    await broadcast_avatar(
        db=db,
        user=user,
        excluded_session_id=excluded_session_id,
    )

    return user

@router.delete(
    '/me/avatar',
    response_model=UserResponse,
)
async def delete_my_avatar(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user = delete_avatar(
        db=db,
        user=current_user,
    )

    device_id = request.headers.get(
        'X-Device-ID'
    )

    excluded_session_id = None

    if device_id:
        device_session = db.scalar(
            select(DeviceSession).where(
                DeviceSession.user_id
                == current_user.id,
                DeviceSession.device_id
                == device_id,
                DeviceSession.is_active.is_(True),
            )
        )

        if device_session is not None:
            excluded_session_id = (
                device_session.session_id
            )

    await broadcast_avatar(
        db=db,
        user=user,
        excluded_session_id=excluded_session_id,
    )

    return user

@router.get(
    '/me/devices',
    response_model=list[DeviceSessionResponse],
)
def get_my_devices(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return get_user_device_sessions(
        db=db,
        user_id=current_user.id,
    )


@router.post(
    '/me/devices',
    response_model=DeviceSessionResponse,
    status_code=status.HTTP_201_CREATED,
)
def register_my_device(
    device_data: DeviceSessionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return create_or_update_device_session(
        db=db,
        user_id=current_user.id,
        device_data=device_data,
    )


@router.delete(
    '/me/devices/{session_id}',
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_my_device(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    deleted = delete_device_session(
        db=db,
        user_id=current_user.id,
        session_id=session_id,
    )

    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail='Device session not found',
        )

    return None

@router.get(
    "/me/sync",
    response_model=AccountSyncResponse,
)
def sync_my_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    friend_sync = get_friend_sync(
        db=db,
        user_id=current_user.id,
    )

    chat_sync = sync_chats(
        db=db,
        user_id=current_user.id,
    )

    return AccountSyncResponse(
        user=current_user,
        friends=friend_sync.friends,
        incoming_requests=friend_sync.incoming_requests,
        outgoing_requests=friend_sync.outgoing_requests,
        chats=chat_sync.chats,
    )