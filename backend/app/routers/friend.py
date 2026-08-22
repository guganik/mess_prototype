from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.database.session import get_db
from app.models.user import User
from app.models.friendship import Friendship

from app.realtime.friend_events import (
    friend_removed_event,
    friend_requested_event,
    friend_updated_event,
)
from app.realtime.manager import manager

from app.schemas.friend import (
    CreateFriendRequest,
    FriendSyncResponse,
    FriendSearchUser
)

from app.services.friend import (
    accept_friend_request,
    create_friend_request,
    get_friend_sync,
    reject_friend_request,
    remove_friend,
    search_users
)


router = APIRouter(
    prefix="/friends",
    tags=["Friends"],
)


@router.get(
    "/sync",
    response_model=FriendSyncResponse,
)
def sync_friends(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return get_friend_sync(
        db=db,
        user_id=current_user.id,
    )


@router.post(
    "/requests",
    status_code=status.HTTP_201_CREATED,
)
async def send_friend_request(
    request_data: CreateFriendRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        friendship = create_friend_request(
            db=db,
            requester_id=current_user.id,
            target_user_id=request_data.user_id,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    await manager.send_to_user(
        request_data.user_id,
        friend_requested_event(
            friendship,
            current_user,
        ),
    )

    return {
        "friendship_id": friendship.id,
    }


@router.post(
    "/requests/{friendship_id}/accept",
)
async def accept_request(
    friendship_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        friendship = accept_friend_request(
            db=db,
            user_id=current_user.id,
            friendship_id=friendship_id,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    requester = db.scalar(
        select(User).where(
            User.id == friendship.requester_id
        )
    )

    if requester is None:
        raise HTTPException(
            status_code=404,
            detail="Requester not found",
        )

    await manager.send_to_user(
        friendship.requester_id,
        friend_updated_event(
            friendship,
            current_user,
        ),
    )

    await manager.send_to_user(
        current_user.id,
        friend_updated_event(
            friendship,
            requester,
        ),
    )

    return {
        "friendship_id": friendship.id,
        "status": friendship.status.value,
    }


@router.post(
    "/requests/{friendship_id}/reject",
)
async def reject_request(
    friendship_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        friendship = reject_friend_request(
            db=db,
            user_id=current_user.id,
            friendship_id=friendship_id,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    await manager.send_to_user(
        friendship.requester_id,
        {
            "type": "friend.request.rejected",
            "data": {
                "friendship_id": friendship.id,
            },
        },
    )

    return {
        "friendship_id": friendship.id,
        "status": friendship.status.value,
    }

@router.get(
    "/search",
    response_model=list[FriendSearchUser],
)
def search_friend_users(
    q: str,
    current_user: User = Depends(
        get_current_user
    ),
    db: Session = Depends(get_db),
):
    return search_users(
        db=db,
        current_user_id=current_user.id,
        query=q,
    )

@router.delete(
    "/{friend_user_id}",
)
async def delete_friend(
    friend_user_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        friendship = db.scalar(
            select(Friendship).where(
                Friendship.user_low_id
                == min(current_user.id, friend_user_id),
                Friendship.user_high_id
                == max(current_user.id, friend_user_id),
            )
        )

        if friendship is None:
            raise ValueError(
                "Friendship not found"
            )

        friendship_id = friendship.id

        remove_friend(
            db=db,
            user_id=current_user.id,
            friend_user_id=friend_user_id,
        )

    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    await manager.send_to_user(
        friend_user_id,
        friend_removed_event(
            friendship_id,
            current_user.id,
        ),
    )

    return {"success": True}