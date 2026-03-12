from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from app.core.config import settings
from app.db import get_db
from app.models.entities import User

security = HTTPBearer()


def current_user(
    cred: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)
) -> User:
    try:
        payload = jwt.decode(cred.credentials, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        if payload.get("type") != "access":
            raise HTTPException(status_code=401, detail="invalid token type")
        uid = int(payload.get("sub"))
    except JWTError:
        raise HTTPException(status_code=401, detail="invalid token")
    user = db.get(User, uid)
    if not user or user.disabled:
        raise HTTPException(status_code=401, detail="user unavailable")
    return user
