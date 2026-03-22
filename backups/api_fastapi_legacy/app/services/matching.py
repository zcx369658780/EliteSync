import json
from datetime import datetime
from sqlalchemy.orm import Session
from app.models.entities import User, Answer, Match
from app.core.encryption import cipher


def week_tag() -> str:
    return datetime.utcnow().strftime("%Y-W%W")


def run_weekly_matching(db: Session):
    users = db.query(User).filter_by(disabled=False, verify_status="approved").all()
    tag = week_tag()
    if len(users) < 2:
        return 0

    # 简化规则：按用户ID顺序两两配对 + 从共同答案抽亮点
    for i in range(0, len(users) - 1, 2):
        a, b = users[i], users[i + 1]
        highlights = extract_highlights(db, a.id, b.id)
        db.add(Match(week_tag=tag, user_a=a.id, user_b=b.id, highlights=json.dumps(highlights), drop_released=False))
    db.commit()
    return len(users) // 2


def extract_highlights(db: Session, uid1: int, uid2: int):
    a_map = {a.question_id: cipher.decrypt(a.encrypted_answer) for a in db.query(Answer).filter_by(user_id=uid1, is_draft=False).all()}
    b_map = {a.question_id: cipher.decrypt(a.encrypted_answer) for a in db.query(Answer).filter_by(user_id=uid2, is_draft=False).all()}
    points = []
    for qid, ans in a_map.items():
        if qid in b_map and b_map[qid] == ans:
            points.append(f"在问题{qid}上观点一致")
        if len(points) >= 3:
            break
    return points or ["你们都完成了深度问卷，值得进一步了解"]
