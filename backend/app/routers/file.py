from fastapi import APIRouter, Depends, File as FastAPIFile, HTTPException, UploadFile, status
from fastapi.responses import FileResponse as FastAPIFileResponse

from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.database.session import get_db

from app.models.user import User
from app.models.file import File, FileAccessType

from app.schemas.file import FileResponse
from app.services.file import create_file
from app.storage import file_storage

router = APIRouter(prefix='/files', tags=['Files'])

@router.post('/upload', response_model=FileResponse, status_code=status.HTTP_201_CREATED)
async def upload_file(upload_file: UploadFile = FastAPIFile(...), current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return await create_file(db=db, upload_file=upload_file, owner_id=current_user.id)

@router.get('/{file_id}')
def get_file(file_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    file = db.query(File).filter(File.file_id == file_id).first()

    if file is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail='File not found'
        )

    if file.access_type != FileAccessType.PUBLIC and file.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail='Access denied'
        )

    try:
        path = file_storage.get(file.path)
    except FileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail='File not found on storage'
        )

    return FastAPIFileResponse(path=path, media_type=file.mime_type, filename=file.original_name)

@router.delete('/{file_id}', status_code=status.HTTP_204_NO_CONTENT)
def delete_file(file_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    file = db.query(File).filter(File.file_id == file_id).first()

    if file is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail='File not found'
        )

    if file.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail='Access denied'
        )

    if current_user.avatar_file_id == file.id:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail='Cannot delete current avatar directly'
        )

    path = file.path

    db.delete(file)
    db.commit()

    file_storage.delete(path)

@router.post('/upload/avatar', response_model=FileResponse, status_code=status.HTTP_201_CREATED)
async def upload_avatar(upload_file: UploadFile = FastAPIFile(...), current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return await create_file(db=db, upload_file=upload_file, owner_id=current_user.id, access_type=FileAccessType.PUBLIC)