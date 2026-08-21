from pydantic import BaseModel, ConfigDict, field_validator, computed_field

from datetime import datetime

from app.models.user import UserStatus, UserPresence
from app.validators.user import (
    validate_username,
    validate_first_name,
    validate_email,
    validate_phone
)

from app.schemas.file import FileResponse

class AvatarUpdate(BaseModel):
    file_id: str

class UserUpdate(BaseModel):
    username: str | None = None
    first_name: str | None = None
    email: str | None = None
    phone: str | None = None
    status: UserStatus | None = None

    @field_validator('username')
    @classmethod
    def validate_username_field(cls, value: str | None) -> str | None:
        if value is None: return None

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

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    username: str
    first_name: str | None
    email: str | None
    phone: str | None
    avatar_file: FileResponse | None = None

    @computed_field
    @property
    def avatar_file_id(self) -> str | None:
        if self.avatar_file is None:
            return None

        return self.avatar_file.file_id
    
    status: UserStatus
    presence: UserPresence
    last_seen: datetime | None
    is_active: bool