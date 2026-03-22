from fastapi import APIRouter, Depends, HTTPException
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token
from app.db import get_db
from app.models.entities import User
from app.schemas.api import RegisterReq, LoginReq, TokenResp, RefreshReq

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


@router.post("/register", response_model=TokenResp)
def register(req: RegisterReq, db: Session = Depends(get_db)):
    if db.query(User).filter_by(phone=req.phone).first():
        raise HTTPException(400, "phone exists")
    user = User(phone=req.phone, password_hash=hash_password(req.password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return TokenResp(access_token=create_access_token(str(user.id)), refresh_token=create_refresh_token(str(user.id)))


@router.post("/login", response_model=TokenResp)
def login(req: LoginReq, db: Session = Depends(get_db)):
    user = db.query(User).filter_by(phone=req.phone).first()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(401, "invalid credentials")
    return TokenResp(access_token=create_access_token(str(user.id)), refresh_token=create_refresh_token(str(user.id)))


@router.post("/refresh", response_model=TokenResp)
def refresh(req: RefreshReq):
    try:
        payload = jwt.decode(req.refresh_token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        if payload.get("type") != "refresh":
            raise HTTPException(401, "invalid token type")
        uid = payload.get("sub")
    except JWTError:
        raise HTTPException(401, "invalid refresh token")
    return TokenResp(access_token=create_access_token(uid), refresh_token=create_refresh_token(uid))
