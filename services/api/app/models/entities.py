from datetime import datetime
from sqlalchemy import String, Integer, ForeignKey, DateTime, Text, Boolean, Float
from sqlalchemy.orm import Mapped, mapped_column
from app.models.base import Base


class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    phone: Mapped[str] = mapped_column(String(20), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    nickname: Mapped[str] = mapped_column(String(80), default="新用户")
    verify_status: Mapped[str] = mapped_column(String(20), default="pending")
    disabled: Mapped[bool] = mapped_column(Boolean, default=False)


class Question(Base):
    __tablename__ = "questions"
    id: Mapped[int] = mapped_column(primary_key=True)
    dimension: Mapped[str] = mapped_column(String(50))
    title: Mapped[str] = mapped_column(String(255))
    qtype: Mapped[str] = mapped_column(String(20))
    options_json: Mapped[str] = mapped_column(Text)
    weight: Mapped[int] = mapped_column(Integer, default=1)


class Answer(Base):
    __tablename__ = "answers"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    question_id: Mapped[int] = mapped_column(ForeignKey("questions.id"), index=True)
    encrypted_answer: Mapped[str] = mapped_column(Text)
    is_draft: Mapped[bool] = mapped_column(Boolean, default=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class Match(Base):
    __tablename__ = "matches"
    id: Mapped[int] = mapped_column(primary_key=True)
    week_tag: Mapped[str] = mapped_column(String(16), index=True)
    user_a: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    user_b: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    highlights: Mapped[str] = mapped_column(Text)
    drop_released: Mapped[bool] = mapped_column(Boolean, default=False)
    like_a: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    like_b: Mapped[bool | None] = mapped_column(Boolean, nullable=True)


class Message(Base):
    __tablename__ = "messages"
    id: Mapped[int] = mapped_column(primary_key=True)
    room_id: Mapped[str] = mapped_column(String(32), index=True)
    sender_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    receiver_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    content: Mapped[str] = mapped_column(Text)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserBasicProfile(Base):
    __tablename__ = "user_basic_profiles"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, index=True)
    birthday: Mapped[str | None] = mapped_column(String(10), nullable=True)
    name: Mapped[str | None] = mapped_column(String(80), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class UserAstroProfile(Base):
    __tablename__ = "user_astro_profiles"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, index=True)
    birthday: Mapped[str | None] = mapped_column(String(10), nullable=True)
    birth_time: Mapped[str | None] = mapped_column(String(5), nullable=True)
    birth_place: Mapped[str | None] = mapped_column(String(255), nullable=True)
    birth_lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    birth_lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    tz_str: Mapped[str | None] = mapped_column(String(64), nullable=True)
    natal_chart_svg: Mapped[str | None] = mapped_column(Text, nullable=True)
    natal_chart_json: Mapped[str | None] = mapped_column(Text, nullable=True)
    computed_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
