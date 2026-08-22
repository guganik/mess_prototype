from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token
from app.database.session import get_db
from app.schemas.auth import (
    UserRegister,
    UserLogin,
    TokenResponse
)
from app.schemas.user import UserResponse
from app.services.auth import register_user, authenticate_user

router = APIRouter(prefix='/auth', tags=['Authentication'])

@router.post('/register', response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_data: UserRegister, db: Session = Depends(get_db)):
    try:
        return register_user(db=db, user_data=user_data)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(exc)
        )

@router.post('/login', response_model=TokenResponse)
def login(user_data: UserLogin, db: Session = Depends(get_db)):
    user = authenticate_user(db=db, username=user_data.username, password=user_data.password)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAOTHORIZED,
            detail='Invalid username or password'
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail='User account is inactive'
        )

    access_token = create_access_token(user_id=user.id)

    return TokenResponse(access_token=access_token)