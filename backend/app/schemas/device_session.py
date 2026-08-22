from datetime import datetime

from pydantic import BaseModel, ConfigDict


class DeviceSessionCreate(BaseModel):
    device_id: str
    device_name: str
    platform: str


class DeviceSessionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    session_id: str
    device_id: str
    device_name: str
    platform: str
    created_at: datetime
    last_seen: datetime
    is_active: bool