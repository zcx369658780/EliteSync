from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.deps import current_user
from app.models.entities import User, Answer, Match
from app.schemas.api import VerifyUpdateReq
from app.services.matching import run_weekly_matching, week_tag

router = APIRouter(prefix="/api/v1", tags=["profile-admin"])


@router.get("/me")
def me(user: User = Depends(current_user)):
    return {
        "id": user.id,
        "phone": user.phone,
        "nickname": user.nickname,
        "verify_status": user.verify_status,
    }


@router.put("/me")
def update_me(payload: dict, user: User = Depends(current_user), db: Session = Depends(get_db)):
    user.nickname = payload.get("nickname", user.nickname)
    db.commit()
    return {"ok": True}


@router.get("/admin/users")
def list_users(db: Session = Depends(get_db)):
    return [{"id": u.id, "phone": u.phone, "disabled": u.disabled, "verify_status": u.verify_status} for u in db.query(User).all()]


@router.post("/admin/users/{uid}/disable")
def disable_user(uid: int, db: Session = Depends(get_db)):
    user = db.get(User, uid)
    if not user:
        raise HTTPException(404, "user not found")
    user.disabled = True
    db.commit()
    return {"ok": True}


@router.get("/admin/verify-queue")
def verify_queue(db: Session = Depends(get_db)):
    return [{"id": u.id, "phone": u.phone, "verify_status": u.verify_status} for u in db.query(User).filter(User.verify_status != "approved").all()]


@router.post("/admin/verify/{uid}")
def update_verify(uid: int, req: VerifyUpdateReq, db: Session = Depends(get_db)):
    user = db.get(User, uid)
    if not user:
        raise HTTPException(404, "user not found")
    user.verify_status = req.status
    db.commit()
    return {"ok": True}


@router.get("/admin/stats")
def stats(db: Session = Depends(get_db)):
    dau = db.query(User).count()
    completed = db.query(Answer).filter_by(is_draft=False).count()
    pairs = db.query(Match).count()
    return {"daily_active": dau, "questionnaire_completed": completed, "match_pairs": pairs}


@router.post("/admin/dev/run-matching")
def dev_run_matching(db: Session = Depends(get_db)):
    pairs = run_weekly_matching(db)
    return {"ok": True, "week_tag": week_tag(), "pairs": pairs}


@router.post("/admin/dev/release-drop")
def dev_release_drop(db: Session = Depends(get_db)):
    updated = 0
    for m in db.query(Match).filter_by(week_tag=week_tag()).all():
        m.drop_released = True
        updated += 1
    db.commit()
    return {"ok": True, "week_tag": week_tag(), "released": updated}
