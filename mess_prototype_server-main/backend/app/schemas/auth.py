from pydantic import BaseModel, field_validator

from app.validators.user import (
    validate_username,
    validate_first_name,
    validate_email,
    validate_phone
)

class UserRegister(BaseModel):
    username: str
    password: str
    first_name: str | None = None
    email: str | None = None
    phone: str | None = None

    @field_validator('username')
    @classmethod
    def validate_username_field(cls, value: str) -> str:
        return validate_username(value)

    @field_validator('first_name')
    @classmethod
    def validate_first_name_field(cls, value: str | None) -> str | None:
        return validate_first_name(value)

    @field_validator('email')
    @classmethod
    def validate_email_field(cls, value: str | None) -> str | None:
        return validate_email(value)

    @field_validator('phone')
    @classmethod
    def validate_phone_field(cls, value: str | None) -> str | None:
        return validate_phone(value)

class UserLogin(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = 'bearer'