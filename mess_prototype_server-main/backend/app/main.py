from fastapi import FastAPI

from app.config import settings
from app.routers import auth, file, health, user
from app.realtime import router as realtime

app = FastAPI(
	title=settings.APP_NAME,
	version=settings.VERSION
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(user.router)
app.include_router(file.router)
app.include_router(realtime.router)
