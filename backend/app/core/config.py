from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Optional
import os

class Settings(BaseSettings):
    # App Settings
    PROJECT_NAME: str = "Masjid Connect Pro"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str = "yoursecretkeyforjwt"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Database
    DATABASE_URL: str
    
    # Cloudinary
    CLOUDINARY_URL: str
    
    # Google Auth
    GOOGLE_CLIENT_ID: str
    GOOGLE_CLIENT_SECRET: str
    GOOGLE_PROJECT_ID: str
    
    # Super Admin
    SUPER_ADMIN_EMAILS: str  # Comma separated
    
    # CORS
    CORS_ORIGINS: str  # Comma separated
    
    # Firebase
    FIREBASE_TYPE: str
    FIREBASE_PROJECT_ID: str
    FIREBASE_PRIVATE_KEY_ID: str
    FIREBASE_PRIVATE_KEY: str
    FIREBASE_CLIENT_EMAIL: str
    FIREBASE_CLIENT_ID: str
    FIREBASE_AUTH_URI: str
    FIREBASE_TOKEN_URI: str
    FIREBASE_AUTH_PROVIDER_CERT_URL: str
    FIREBASE_CLIENT_CERT_URL: str

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"),
        env_file_encoding="utf-8",
        extra="ignore"
    )

    @property
    def super_admin_list(self) -> List[str]:
        return [email.strip() for email in self.SUPER_ADMIN_EMAILS.split(",")]

    @property
    def cors_origins_list(self) -> List[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]

settings = Settings()
