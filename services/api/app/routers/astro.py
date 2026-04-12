from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.db import get_db
from app.deps import current_user
from app.models.entities import User, UserAstroProfile, UserBasicProfile
from app.schemas.api import AstroPairReq, AstroProfileReq, AstroRenderReq, AstroReturnReq, AstroTransitReq
from app.services.astro import (
    build_natal_chart_payload,
    build_pair_chart_payload,
    build_return_chart_payload,
    build_transit_chart_payload,
    serialize_chart_json,
)

router = APIRouter(prefix="/api/v1/profile", tags=["astro"])


@router.get("/astro")
def get_astro_profile(
    user: User = Depends(current_user),
    db: Session = Depends(get_db),
    route_mode: str = Query('standard'),
):
    row = db.query(UserAstroProfile).filter_by(user_id=user.id).first()
    basic = db.query(UserBasicProfile).filter_by(user_id=user.id).first()
    if not row:
        return {"exists": False, "profile": None}

    birthday = row.birthday or (basic.birthday if basic else None)
    birth_time = row.birth_time
    if not birthday or not birth_time:
        return {
            "exists": False,
            "profile": None,
            "reason": "missing_required_birth_fields",
        }

    try:
        payload = build_natal_chart_payload(
            name=(basic.name if basic and basic.name else user.nickname),
            birthday=birthday,
            birth_time=birth_time,
            birth_place=row.birth_place,
            birth_lat=row.birth_lat,
            birth_lng=row.birth_lng,
            tz_str=row.tz_str,
            route_mode=route_mode,
        )
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    row.birthday = birthday
    row.natal_chart_json = serialize_chart_json(payload["chart_data"])
    row.computed_at = datetime.utcnow()
    db.commit()
    return {
        "exists": True,
        "profile": {
            "birthday": birthday,
            "birth_time": row.birth_time,
            "birth_place": row.birth_place,
            "birth_lat": row.birth_lat,
            "birth_lng": row.birth_lng,
            "tz_str": row.tz_str or "Asia/Shanghai",
            "chart_data": payload["chart_data"],
            "planets_data": payload["planets_data"],
            "aspects_data": payload["aspects_data"],
            "houses_data": payload["houses_data"],
            "route_mode": payload["route_mode"],
            "engine_info": payload["engine_info"],
            "metadata": payload["metadata"],
            "generated_at": payload["generated_at"],
            "computed_at": row.computed_at.isoformat() + "Z",
        },
    }


@router.post("/astro")
def save_astro_profile(req: AstroProfileReq, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if req.birthday and len(req.birthday) != 10:
        raise HTTPException(status_code=400, detail="invalid birthday format")
    if req.birth_time and len(req.birth_time) != 5:
        raise HTTPException(status_code=400, detail="invalid birth_time format")

    basic = db.query(UserBasicProfile).filter_by(user_id=user.id).first()
    if not basic:
        basic = UserBasicProfile(user_id=user.id, birthday=req.birthday, name=user.nickname)
        db.add(basic)
    else:
        basic.birthday = req.birthday
        basic.name = basic.name or user.nickname

    row = db.query(UserAstroProfile).filter_by(user_id=user.id).first()
    if not row:
        row = UserAstroProfile(user_id=user.id)
        db.add(row)

    row.birthday = req.birthday
    row.birth_time = req.birth_time
    row.birth_place = req.birth_place
    row.birth_lat = req.birth_lat
    row.birth_lng = req.birth_lng
    row.tz_str = req.tz_str or "Asia/Shanghai"

    try:
        payload = build_natal_chart_payload(
            name=(basic.name if basic and basic.name else user.nickname),
            birthday=req.birthday,
            birth_time=req.birth_time,
            birth_place=req.birth_place,
            birth_lat=req.birth_lat,
            birth_lng=req.birth_lng,
            tz_str=row.tz_str,
            route_mode=req.route_mode,
        )
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    row.natal_chart_json = serialize_chart_json(payload["chart_data"])
    row.computed_at = datetime.utcnow()
    db.commit()

    return {
        "ok": True,
        "profile": {
            "birthday": row.birthday,
            "birth_time": row.birth_time,
            "birth_place": row.birth_place,
            "birth_lat": row.birth_lat,
            "birth_lng": row.birth_lng,
            "tz_str": row.tz_str,
            "chart_data": payload["chart_data"],
            "planets_data": payload["planets_data"],
            "aspects_data": payload["aspects_data"],
            "houses_data": payload["houses_data"],
            "route_mode": payload["route_mode"],
            "engine_info": payload["engine_info"],
            "metadata": payload["metadata"],
            "generated_at": payload["generated_at"],
            "computed_at": row.computed_at.isoformat() + "Z",
        },
    }


@router.post("/astro/render")
def render_astro(req: AstroRenderReq):
    try:
        payload = build_natal_chart_payload(
            name=(req.name or "EliteSync"),
            birthday=req.birthday,
            birth_time=req.birth_time,
            birth_place=req.birth_place,
            birth_lat=req.birth_lat,
            birth_lng=req.birth_lng,
            tz_str=req.tz_str,
            route_mode=req.route_mode,
        )
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    return {
        "ok": True,
        "profile": {
            "birthday": req.birthday,
            "birth_time": req.birth_time,
            "birth_place": req.birth_place,
            "birth_lat": req.birth_lat,
            "birth_lng": req.birth_lng,
            "tz_str": req.tz_str or "Asia/Shanghai",
            "chart_data": payload["chart_data"],
            "planets_data": payload["planets_data"],
            "aspects_data": payload["aspects_data"],
            "houses_data": payload["houses_data"],
            "route_mode": payload["route_mode"],
            "engine_info": payload["engine_info"],
            "metadata": payload["metadata"],
            "generated_at": payload["generated_at"],
        },
    }


@router.post("/astro/pair")
def pair_astro(req: AstroPairReq):
    payload = build_pair_chart_payload(
        first=req.first.model_dump(),
        second=req.second.model_dump(),
        pair_mode=req.pair_mode,
        route_mode=req.route_mode,
    )
    return {"ok": True, "profile": payload}


@router.post("/astro/transit")
def transit_astro(req: AstroTransitReq):
    payload = build_transit_chart_payload(
        natal=req.natal.model_dump(),
        transit=req.transit.model_dump(),
        route_mode=req.route_mode,
    )
    return {"ok": True, "profile": payload}


@router.post("/astro/return")
def return_astro(req: AstroReturnReq):
    payload = build_return_chart_payload(
        natal=req.natal.model_dump(),
        return_year=req.return_year,
        return_type=req.return_type,
        route_mode=req.route_mode,
        return_place=req.return_place,
        return_lat=req.return_lat,
        return_lng=req.return_lng,
        return_tz_str=req.return_tz_str,
        return_nation=req.return_nation,
    )
    return {"ok": True, "profile": payload}
