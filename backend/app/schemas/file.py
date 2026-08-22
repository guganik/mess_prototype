from datetime import datetime

from pydantic import BaseModel, ConfigDict

class FileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    file_id: str
    original_name: str
    mime_type: str
    size: int
    created_at: datetime