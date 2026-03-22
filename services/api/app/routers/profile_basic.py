from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.deps import current_user
from app.models.entities import User, UserBasicProfile
from app.schemas.api import BasicProfileReq

router = APIRouter(prefix="/api/v1/profile", tags=["profile"])


@router.get("/basic")
def basic_profile(user: User = Depends(current_user), db: Session = Depends(get_db)):
    row = db.query(UserBasicProfile).filter_by(user_id=user.id).first()
    return {
        "id": user.id,
        "name": (row.name if row and row.name else user.nickname),
        "phone": user.phone,
        "birthday": row.birthday if row else None,
        "realname_verified": user.verify_status == "approved",
    }


@router.post("/basic")
def save_basic_profile(req: BasicProfileReq, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if req.birthday and len(req.birthday) != 10:
        raise HTTPException(status_code=400, detail="invalid birthday format")

    row = db.query(UserBasicProfile).filter_by(user_id=user.id).first()
    if not row:
        row = UserBasicProfile(user_id=user.id)
        db.add(row)

    row.birthday = req.birthday
    if req.name is not None:
        row.name = req.name.strip() if req.name else None
        if row.name:
            user.nickname = row.name
    row.updated_at = datetime.utcnow()
    db.commit()

    return {"ok": True}

