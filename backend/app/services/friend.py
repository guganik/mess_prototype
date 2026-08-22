from sqlalchemy import or_, select, func
from sqlalchemy.orm import Session

from app.models.friendship import (
    Friendship,
    FriendshipStatus,
)
from app.models.user import User
from app.schemas.friend import (
    FriendResponse,
    FriendRequestResponse,
    FriendSyncResponse,
    FriendUser,
    FriendSearchUser
)


def _friend_user(user: User) -> FriendUser:
    return FriendUser(
        id=user.id,
        username=user.username,
        first_name=user.first_name,
        avatar_file_id=(
            user.avatar_file.file_id
            if user.avatar_file
            else None
        ),
        status=user.status.value,
        presence=user.presence.value,
        last_seen=user.last_seen,
    )


def _get_friend_user(
    friendship: Friendship,
    user_id: int,
    db: Session,
) -> User:
    friend_id = (
        friendship.addressee_id
        if friendship.requester_id == user_id
        else friendship.requester_id
    )

    return db.scalar(
        select(User).where(User.id == friend_id)
    )


def get_friend_sync(
    db: Session,
    user_id: int,
) -> FriendSyncResponse:
    rows = db.scalars(
        select(Friendship)
        .where(
            or_(
                Friendship.requester_id == user_id,
                Friendship.addressee_id == user_id,
            )
        )
    ).all()

    friends = []
    incoming = []
    outgoing = []

    for friendship in rows:
        friend_user = _get_friend_user(
            friendship,
            user_id,
            db,
        )

        if friendship.status == FriendshipStatus.ACCEPTED:
            friends.append(
                FriendResponse(
                    friendship_id=friendship.id,
                    user=_friend_user(friend_user),
                    created_at=friendship.created_at,
                )
            )

        elif (
            friendship.status
            == FriendshipStatus.PENDING
        ):
            item = FriendRequestResponse(
                friendship_id=friendship.id,
                user=_friend_user(friend_user),
                created_at=friendship.created_at,
            )

            if friendship.addressee_id == user_id:
                incoming.append(item)
            else:
                outgoing.append(item)

    return FriendSyncResponse(
        friends=friends,
        incoming_requests=incoming,
        outgoing_requests=outgoing,
    )


def create_friend_request(
    db: Session,
    requester_id: int,
    target_user_id: int,
) -> Friendship:
    if requester_id == target_user_id:
        raise ValueError(
            "Cannot send friend request to yourself"
        )

    target = db.scalar(
        select(User).where(
            User.id == target_user_id
        )
    )

    if target is None:
        raise ValueError("User not found")

    low_id = min(
        requester_id,
        target_user_id,
    )
    high_id = max(
        requester_id,
        target_user_id,
    )

    friendship = db.scalar(
        select(Friendship).where(
            Friendship.user_low_id == low_id,
            Friendship.user_high_id == high_id,
        )
    )

    if friendship is not None:
        if friendship.status == FriendshipStatus.ACCEPTED:
            raise ValueError(
                "Users are already friends"
            )

        if friendship.status == FriendshipStatus.PENDING:
            raise ValueError(
                "Friend request already exists"
            )

        friendship.requester_id = requester_id
        friendship.addressee_id = target_user_id
        friendship.status = FriendshipStatus.PENDING

    else:
        friendship = Friendship(
            requester_id=requester_id,
            addressee_id=target_user_id,
            user_low_id=low_id,
            user_high_id=high_id,
            status=FriendshipStatus.PENDING,
        )

        db.add(friendship)

    db.commit()
    db.refresh(friendship)

    return friendship


def accept_friend_request(
    db: Session,
    user_id: int,
    friendship_id: int,
) -> Friendship:
    friendship = db.scalar(
        select(Friendship).where(
            Friendship.id == friendship_id
        )
    )

    if friendship is None:
        raise ValueError(
            "Friend request not found"
        )

    if friendship.addressee_id != user_id:
        raise ValueError(
            "You cannot accept this request"
        )

    if friendship.status != FriendshipStatus.PENDING:
        raise ValueError(
            "Friend request is not pending"
        )

    friendship.status = FriendshipStatus.ACCEPTED

    db.commit()
    db.refresh(friendship)

    return friendship


def reject_friend_request(
    db: Session,
    user_id: int,
    friendship_id: int,
) -> Friendship:
    friendship = db.scalar(
        select(Friendship).where(
            Friendship.id == friendship_id
        )
    )

    if friendship is None:
        raise ValueError(
            "Friend request not found"
        )

    if friendship.addressee_id != user_id:
        raise ValueError(
            "You cannot reject this request"
        )

    if friendship.status != FriendshipStatus.PENDING:
        raise ValueError(
            "Friend request is not pending"
        )

    friendship.status = FriendshipStatus.REJECTED

    db.commit()
    db.refresh(friendship)

    return friendship


def remove_friend(
    db: Session,
    user_id: int,
    friend_user_id: int,
) -> None:
    friendship = db.scalar(
        select(Friendship).where(
            Friendship.user_low_id
            == min(user_id, friend_user_id),
            Friendship.user_high_id
            == max(user_id, friend_user_id),
        )
    )

    if friendship is None:
        raise ValueError(
            "Friendship not found"
        )

    if friendship.status != FriendshipStatus.ACCEPTED:
        raise ValueError(
            "Users are not friends"
        )

    db.delete(friendship)
    db.commit()

def search_users(
    db: Session,
    current_user_id: int,
    query: str,
    limit: int = 20,
):
    query = query.strip()

    if not query:
        return []

    query = query.lstrip("@").strip()

    if not query:
        return []

    users = db.scalars(
        select(User)
        .where(
            User.id != current_user_id,
            User.is_active.is_(True),
            or_(
                User.username.ilike(
                    f"%{query}%"
                ),
                User.first_name.ilike(
                    f"%{query}%"
                ),
            ),
        )
        .order_by(
            User.username.asc()
        )
        .limit(min(limit, 20))
    ).all()

    result = []

    for user in users:
        low_id = min(
            current_user_id,
            user.id,
        )

        high_id = max(
            current_user_id,
            user.id,
        )

        friendship = db.scalar(
            select(Friendship).where(
                Friendship.user_low_id == low_id,
                Friendship.user_high_id == high_id,
            )
        )

        relation = "none"

        if friendship is not None:
            if (
                friendship.status
                == FriendshipStatus.ACCEPTED
            ):
                relation = "friends"

            elif (
                friendship.status
                == FriendshipStatus.PENDING
            ):
                if (
                    friendship.requester_id
                    == current_user_id
                ):
                    relation = "pending_outgoing"
                else:
                    relation = "pending_incoming"

            elif (
                friendship.status
                == FriendshipStatus.REJECTED
            ):
                relation = "rejected"

            elif (
                friendship.status
                == FriendshipStatus.BLOCKED
            ):
                relation = "blocked"

        result.append(
            FriendSearchUser(
                id=user.id,
                username=user.username,
                first_name=user.first_name,
                avatar_file_id=(
                    user.avatar_file.file_id
                    if user.avatar_file
                    else None
                ),
                status=user.status.value,
                presence=user.presence.value,
                last_seen=user.last_seen,
                is_active=user.is_active,
                relation=relation,
            )
        )

    return result