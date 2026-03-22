from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.deps import current_user
from app.models.entities import User, Match
from app.schemas.api import MatchConfirmReq

router = APIRouter(prefix="/api/v1/matches", tags=["match"])


def _week_tag() -> str:
    return datetime.utcnow().strftime("%Y-W%W")


@router.get("/current")
def current_match(user: User = Depends(current_user), db: Session = Depends(get_db)):
    match = (
        db.query(Match)
        .filter(Match.week_tag == _week_tag(), ((Match.user_a == user.id) | (Match.user_b == user.id)))
        .first()
    )
    if not match or not match.drop_released:
        raise HTTPException(404, "drop not available")
    partner_id = match.user_b if match.user_a == user.id else match.user_a
    return {"match_id": match.id, "partner_id": partner_id, "highlights": match.highlights}


@router.post("/confirm")
def confirm(req: MatchConfirmReq, user: User = Depends(current_user), db: Session = Depends(get_db)):
    match = db.get(Match, req.match_id)
    if not match:
        raise HTTPException(404, "match not found")
    if user.id == match.user_a:
        match.like_a = req.like
    elif user.id == match.user_b:
        match.like_b = req.like
    else:
        raise HTTPException(403, "not in match")
    db.commit()
    success = match.like_a is True and match.like_b is True
    return {"mutual": success}
