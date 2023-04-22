from pydantic import BaseSettings
from typing import Optional


class Env(BaseSettings):
    SECRET_KEY: str
    DEBUG: bool = False
    RDS_HOSTNAME: Optional[str] = None
    RDS_DB_NAME: Optional[str] = None
    RDS_USERNAME: Optional[str] = None
    RDS_PASSWORD: Optional[str] = None
    RDS_PORT: Optional[str] = None

    class Config:
        env_file = ".env.app"
        case_sensitive = True


env = Env()
