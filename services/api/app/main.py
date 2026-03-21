import json
from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI
from sqlalchemy.orm import Session
from app.db import engine, SessionLocal
from app.models.base import Base
from app.models.entities import Question, Match
from app.routers import auth, questionnaire, match, chat, profile_admin, profile_basic
from app.services.matching import run_weekly_matching, week_tag

app = FastAPI(title="EliteSync API P0")
Base.metadata.create_all(bind=engine)


def seed_questions(db: Session):
    if db.query(Question).count() > 0:
        return
    dimensions = ["价值观", "婚恋观", "生活方式", "沟通", "边界"]
    for i in range(1, 67):
        qtype = "single" if i % 3 == 1 else ("multi" if i % 3 == 2 else "scale")
        opts = ["A", "B", "C", "D"] if qtype != "scale" else ["1", "2", "3", "4", "5"]
        db.add(Question(dimension=dimensions[i % len(dimensions)], title=f"第{i}题：占位问题", qtype=qtype, options_json=json.dumps(opts), weight=(i % 5) + 1))
    db.commit()


def release_drop(db: Session):
    for m in db.query(Match).filter_by(week_tag=week_tag()).all():
        m.drop_released = True
    db.commit()


@app.on_event("startup")
def on_startup():
    db = SessionLocal()
    seed_questions(db)
    db.close()

    scheduler = BackgroundScheduler(timezone="Asia/Shanghai")
    scheduler.add_job(lambda: run_weekly_matching(SessionLocal()), "cron", day_of_week="tue", hour=0, minute=0)
    scheduler.add_job(lambda: release_drop(SessionLocal()), "cron", day_of_week="tue", hour=21, minute=0)
    scheduler.start()


@app.get("/health")
def health():
    return {"status": "ok"}


app.include_router(auth.router)
app.include_router(questionnaire.router)
app.include_router(match.router)
app.include_router(chat.router)
app.include_router(profile_admin.router)
app.include_router(profile_basic.router)
