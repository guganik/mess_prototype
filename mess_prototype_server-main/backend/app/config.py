from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
  APP_NAME: str
  VERSION: str

  DATABASE_URL: str

  SECRET_KEY: str
  ALGORITHM: str = 'HS256'
  ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080

  FILES_STORAGE_PATH: str

  class Config:
    env_file = ".env"
    env_file_encoding='utf-8'
    extra='ignore'

settings = Settings()