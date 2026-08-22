import mimetypes
from pathlib import Path
from uuid import uuid4

from fastapi import UploadFile
from sqlalchemy.orm import Session

from app.models.file import File, FileAccessType
from app.storage import file_storage

async def create_file(db: Session, upload_file: UploadFile, owner_id: int, access_type: FileAccessType = FileAccessType.PRIVATE) -> File:
    content = await upload_file.read()

    original_name = upload_file.filename or 'file'

    extension = Path(original_name).suffix.lower()

    file_id = str(uuid4())

    file = File(
        file_id=file_id,
        owner_id=owner_id,
        access_type=access_type,
        original_name=upload_file.filename or 'file',
        mime_type=upload_file.content_type
            or mimetypes.guess_type(original_name)[0]
            or 'application/octet-stream',
        size=len(content)
    )

    path: str | None = None

    try:
        stored_name, path = file_storage.save(
            file_id=file_id,
            extension=extension,
            content=content
        )

        file.stored_name = stored_name
        file.path = path

        db.add(file)
        db.commit()
        db.refresh(file)

        return file

    except Exception:
        db.rollback()

        if path is not None:
            file_storage.delete(path)

        raise