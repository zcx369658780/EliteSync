from pydantic import BaseModel
from typing import List


class RegisterReq(BaseModel):
    phone: str
    password: str


class LoginReq(BaseModel):
    phone: str
    password: str


class TokenResp(BaseModel):
    access_token: str
    refresh_token: str


class RefreshReq(BaseModel):
    refresh_token: str


class VerifyUpdateReq(BaseModel):
    status: str


class AnswerItem(BaseModel):
    question_id: int
    answer: str
    is_draft: bool = True


class SubmitAnswersReq(BaseModel):
    answers: List[AnswerItem]


class MatchConfirmReq(BaseModel):
    match_id: int
    like: bool


class MessageReq(BaseModel):
    receiver_id: int
    content: str


class BasicProfileReq(BaseModel):
    birthday: str | None = None
    name: str | None = None
