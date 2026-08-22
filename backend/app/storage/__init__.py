from app.config import settings
from app.storage.file_storage import FileStorage

file_storage = FileStorage(settings.FILES_STORAGE_PATH)