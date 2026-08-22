from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def root():
  return {
    "message": "Googa server works!",
    "status": "ok"
  }

@router.get("/health")
def health():
  return {
    "status": "healthy"
  }