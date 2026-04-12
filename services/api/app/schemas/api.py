from pydantic import BaseModel
from typing import List, Literal


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


class AstroProfileReq(BaseModel):
    birthday: str
    birth_time: str
    birth_place: str | None = None
    birth_lat: float | None = None
    birth_lng: float | None = None
    tz_str: str | None = "Asia/Shanghai"
    route_mode: str | None = "standard"


class AstroSubjectReq(BaseModel):
    name: str | None = None
    birthday: str
    birth_time: str
    birth_place: str | None = None
    birth_lat: float | None = None
    birth_lng: float | None = None
    tz_str: str | None = "Asia/Shanghai"
    nation: str | None = "CN"


class AstroPairReq(BaseModel):
    first: AstroSubjectReq
    second: AstroSubjectReq
    pair_mode: Literal["synastry", "comparison"] = "synastry"
    route_mode: str | None = "standard"


class AstroTransitReq(BaseModel):
    natal: AstroSubjectReq
    transit: AstroSubjectReq
    route_mode: str | None = "standard"


class AstroReturnReq(BaseModel):
    natal: AstroSubjectReq
    return_year: int
    return_type: Literal["Lunar", "Solar"] = "Lunar"
    route_mode: str | None = "standard"
    return_place: str | None = None
    return_lat: float | None = None
    return_lng: float | None = None
    return_tz_str: str | None = None
    return_nation: str | None = None



class AstroRenderReq(BaseModel):
    name: str | None = None
    birthday: str
    birth_time: str
    birth_place: str | None = None
    birth_lat: float | None = None
    birth_lng: float | None = None
    tz_str: str | None = "Asia/Shanghai"
    route_mode: str | None = "standard"
