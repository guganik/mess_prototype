from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session


from app.auth.dependencies import get_current_user

from app.database.session import get_db

from app.models.user import User

from app.services.user import update_user, update_avatar, delete_avatar

from app.schemas.user import UserResponse, UserUpdate, AvatarUpdate


router = APIRouter(
    prefix='/users',
    tags=['Users']
)

@router.get('/me', response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.patch('/me', response_model=UserResponse)
def update_me(user_data: UserUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        return update_user(db=db, user=current_user, user_data=user_data)
    
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(exc)
        )

@router.patch('/me/avatar', response_model=UserResponse)
def update_my_avatar(avatar_data: AvatarUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        return update_avatar(db=db, user=current_user, file_id=avatar_data.file_id)

    except ValueError as exc:
        if str(exc) == 'File not found':
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(exc)
            )

        if str(exc) == 'Access denied':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=str(exc)
            )

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc)
        )

@router.delete('/me/avatar', response_model=UserResponse)
def delete_my_avatar(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return delete_avatar(db=db, user=current_user)