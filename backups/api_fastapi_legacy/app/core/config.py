from pydantic import BaseModel


class Settings(BaseModel):
    app_name: str = "EliteSync API"
    jwt_secret: str = "dev-secret"
    jwt_algorithm: str = "HS256"
    access_token_minutes: int = 30
    refresh_token_days: int = 14
    aes_key: str = "0123456789abcdef0123456789abcdef"  # 32-byte
    drop_hour: int = 21


settings = Settings()
