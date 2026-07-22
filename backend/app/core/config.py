from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "Cohabio AI Relocation & Community API"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "super_secret_cohabio_key_change_in_production_2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # Database
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "cohabio"
    POSTGRES_PORT: str = "5432"
    DATABASE_URL: Optional[str] = None

    # Supabase & Cloud
    SUPABASE_URL: Optional[str] = "https://your-supabase-project.supabase.co"
    SUPABASE_KEY: Optional[str] = "anon-key-placeholder"

    # AI & Services
    GEMINI_API_KEY: Optional[str] = "gemini-api-key-placeholder"
    REDIS_URL: Optional[str] = "redis://localhost:6379/0"

    class Config:
        case_sensitive = True
        env_file = ".env"

    def get_database_url(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

settings = Settings()
