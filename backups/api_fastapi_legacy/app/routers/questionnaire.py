import json
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.deps import current_user
from app.models.entities import Question, Answer, User
from app.schemas.api import SubmitAnswersReq
from app.core.encryption import cipher

router = APIRouter(prefix="/api/v1/questions", tags=["questionnaire"])


@router.get("")
def list_questions(db: Session = Depends(get_db)):

    qs = db.query(Question).order_by(Question.id).all()
    if not qs:
        from app.main import seed_questions
        seed_questions(db)
        qs = db.query(Question).order_by(Question.id).all()
    return [
        {
            "id": q.id,
            "dimension": q.dimension,
            "title": q.title,
            "type": q.qtype,
            "options": json.loads(q.options_json),
            "weight": q.weight,
        }
        for q in qs
    ]


@router.post("/answers")
def submit_answers(req: SubmitAnswersReq, user: User = Depends(current_user), db: Session = Depends(get_db)):
    for item in req.answers:
        row = db.query(Answer).filter_by(user_id=user.id, question_id=item.question_id).first()
        encrypted = cipher.encrypt(item.answer)
        if row:
            row.encrypted_answer = encrypted
            row.is_draft = item.is_draft
        else:
            db.add(Answer(user_id=user.id, question_id=item.question_id, encrypted_answer=encrypted, is_draft=item.is_draft))
    db.commit()
    return {"saved": len(req.answers)}


@router.get("/answers/progress")
def progress(user: User = Depends(current_user), db: Session = Depends(get_db)):
    total = db.query(Question).count()
    done = db.query(Answer).filter_by(user_id=user.id, is_draft=False).count()
    drafts = db.query(Answer).filter_by(user_id=user.id, is_draft=True).count()
    return {"total": total, "done": done, "drafts": drafts}
