import json
from importlib.metadata import PackageNotFoundError, version
from datetime import datetime
from typing import Any

from kerykeion import AstrologicalSubjectFactory, ChartDataFactory, PlanetaryReturnFactory

SCHEMA_VERSION = "astro_engine_mvp_v1"
ENGINE_NAME = "kerykeion"


def build_natal_chart_payload(
    *,
    name: str,
    birthday: str,
    birth_time: str,
    birth_place: str | None,
    birth_lat: float | None,
    birth_lng: float | None,
    tz_str: str | None,
    route_mode: str | None = "standard",
) -> dict[str, Any]:
    normalized_route_mode = _normalize_route_mode(route_mode)
    subject = _build_subject(
        name=name,
        birthday=birthday,
        birth_time=birth_time,
        birth_place=birth_place,
        birth_lat=birth_lat,
        birth_lng=birth_lng,
        tz_str=tz_str,
    )
    chart_data = ChartDataFactory.create_natal_chart_data(subject)
    chart_dump = chart_data.model_dump()
    subject_dump = chart_dump.get("subject", {}) if isinstance(chart_dump, dict) else {}
    metadata = _build_metadata(normalized_route_mode, chart_kind="natal")
    return {
        "chart_data": chart_dump,
        "planets_data": _build_planets_data(subject_dump),
        "houses_data": _build_houses_data(subject_dump),
        "aspects_data": _build_aspects_data(chart_dump),
        "route_mode": normalized_route_mode,
        "engine_info": {
            "engine_name": ENGINE_NAME,
            "engine_version": metadata["engine_version"],
            "schema_version": SCHEMA_VERSION,
            "chart_kind": "natal",
        },
        "metadata": metadata,
        "generated_at": datetime.utcnow().isoformat() + "Z",
    }


def build_pair_chart_payload(
    *,
    first: dict[str, Any],
    second: dict[str, Any],
    pair_mode: str = "synastry",
    route_mode: str | None = "standard",
) -> dict[str, Any]:
    normalized_route_mode = _normalize_route_mode(route_mode)
    normalized_pair_mode = _normalize_pair_mode(pair_mode)
    first_subject = _build_subject_from_dict(first)
    second_subject = _build_subject_from_dict(second)
    include_relationship_score = normalized_pair_mode == "synastry"
    chart_data = ChartDataFactory.create_synastry_chart_data(
        first_subject,
        second_subject,
        include_relationship_score=include_relationship_score,
    )
    chart_dump = chart_data.model_dump()
    first_dump = first_subject.model_dump()
    second_dump = second_subject.model_dump()
    metadata = _build_metadata(
        normalized_route_mode,
        chart_kind="synastry",
        advanced_mode="pair",
        advanced_context={
            "mode": "pair",
            "pair_mode": normalized_pair_mode,
            "source": "derived_only",
            "scope": "preview",
        },
    )
    metadata["field_roles"]["derived"] = _merge_unique_fields(
        metadata["field_roles"]["derived"],
        [
            "primary_subject",
            "secondary_subject",
            "primary_planets_data",
            "primary_houses_data",
            "secondary_planets_data",
            "secondary_houses_data",
            "house_comparison",
            "relationship_score",
            "advanced_summary",
            "pair_mode",
        ],
    )
    metadata["field_roles"]["advanced_context"] = [
        "pair_context",
        "comparison_context",
        "time_context",
        "return_context",
    ]
    return {
        "chart_data": chart_dump,
        "primary_subject": _build_subject_snapshot(first_dump),
        "secondary_subject": _build_subject_snapshot(second_dump),
        "primary_planets_data": _build_planets_data(first_dump),
        "primary_houses_data": _build_houses_data(first_dump),
        "secondary_planets_data": _build_planets_data(second_dump),
        "secondary_houses_data": _build_houses_data(second_dump),
        "aspects_data": _build_aspects_data(chart_dump),
        "house_comparison": chart_dump.get("house_comparison"),
        "relationship_score": chart_dump.get("relationship_score"),
        "pair_mode": normalized_pair_mode,
        "advanced_mode": "pair",
        "advanced_summary": _build_advanced_summary(
            "pair",
            chart_dump,
            first_dump,
            second_dump,
            pair_mode=normalized_pair_mode,
        ),
        "route_mode": normalized_route_mode,
        "engine_info": {
            "engine_name": ENGINE_NAME,
            "engine_version": metadata["engine_version"],
            "schema_version": SCHEMA_VERSION,
            "chart_kind": "synastry",
            "advanced_mode": "pair",
        },
        "metadata": metadata,
        "generated_at": datetime.utcnow().isoformat() + "Z",
    }


def build_transit_chart_payload(
    *,
    natal: dict[str, Any],
    transit: dict[str, Any],
    route_mode: str | None = "standard",
) -> dict[str, Any]:
    normalized_route_mode = _normalize_route_mode(route_mode)
    natal_subject = _build_subject_from_dict(natal)
    transit_subject = _build_subject_from_dict(transit)
    chart_data = ChartDataFactory.create_transit_chart_data(
        natal_subject,
        transit_subject,
    )
    chart_dump = chart_data.model_dump()
    natal_dump = natal_subject.model_dump()
    transit_dump = transit_subject.model_dump()
    metadata = _build_metadata(
        normalized_route_mode,
        chart_kind="transit",
        advanced_mode="transit",
        advanced_context={
            "mode": "transit",
            "source": "derived_only",
            "scope": "preview",
        },
    )
    metadata["field_roles"]["derived"] = _merge_unique_fields(
        metadata["field_roles"]["derived"],
        [
            "primary_subject",
            "secondary_subject",
            "primary_planets_data",
            "primary_houses_data",
            "secondary_planets_data",
            "secondary_houses_data",
            "house_comparison",
            "relationship_score",
            "advanced_summary",
        ],
    )
    metadata["field_roles"]["advanced_context"] = [
        "time_context",
        "comparison_context",
    ]
    return {
        "chart_data": chart_dump,
        "primary_subject": _build_subject_snapshot(natal_dump),
        "secondary_subject": _build_subject_snapshot(transit_dump),
        "primary_planets_data": _build_planets_data(natal_dump),
        "primary_houses_data": _build_houses_data(natal_dump),
        "secondary_planets_data": _build_planets_data(transit_dump),
        "secondary_houses_data": _build_houses_data(transit_dump),
        "aspects_data": _build_aspects_data(chart_dump),
        "house_comparison": chart_dump.get("house_comparison"),
        "relationship_score": chart_dump.get("relationship_score"),
        "advanced_mode": "transit",
        "advanced_summary": _build_advanced_summary(
            "transit",
            chart_dump,
            natal_dump,
            transit_dump,
        ),
        "route_mode": normalized_route_mode,
        "engine_info": {
            "engine_name": ENGINE_NAME,
            "engine_version": metadata["engine_version"],
            "schema_version": SCHEMA_VERSION,
            "chart_kind": "transit",
            "advanced_mode": "transit",
        },
        "metadata": metadata,
        "generated_at": datetime.utcnow().isoformat() + "Z",
    }


def build_return_chart_payload(
    *,
    natal: dict[str, Any],
    return_year: int,
    return_type: str = "Lunar",
    route_mode: str | None = "standard",
    return_place: str | None = None,
    return_lat: float | None = None,
    return_lng: float | None = None,
    return_tz_str: str | None = None,
    return_nation: str | None = None,
) -> dict[str, Any]:
    normalized_route_mode = _normalize_route_mode(route_mode)
    natal_subject = _build_subject_from_dict(natal)
    natal_dump = natal_subject.model_dump()
    location_city = (return_place or natal.get("birth_place") or natal_dump.get("city") or "").strip() or None
    location_nation = (return_nation or natal.get("nation") or natal_dump.get("nation") or "CN").strip() or "CN"
    location_lat = return_lat if return_lat is not None else natal.get("birth_lat") or natal_dump.get("lat")
    location_lng = return_lng if return_lng is not None else natal.get("birth_lng") or natal_dump.get("lng")
    location_tz = (return_tz_str or natal.get("tz_str") or natal_dump.get("tz_str") or "Asia/Shanghai").strip() or "Asia/Shanghai"
    return_factory = PlanetaryReturnFactory(
        natal_subject,
        city=location_city,
        nation=location_nation,
        lng=location_lng,
        lat=location_lat,
        tz_str=location_tz,
        online=False,
    )
    return_subject = return_factory.next_return_from_year(return_year, return_type=return_type)
    chart_data = ChartDataFactory.create_return_chart_data(natal_subject, return_subject)
    chart_dump = chart_data.model_dump()
    return_dump = return_subject.model_dump()
    metadata = _build_metadata(
        normalized_route_mode,
        chart_kind="return",
        advanced_mode="return",
        advanced_context={
            "mode": "return",
            "return_type": return_type,
            "return_year": return_year,
            "source": "derived_only",
            "scope": "preview",
        },
    )
    metadata["field_roles"]["derived"] = _merge_unique_fields(
        metadata["field_roles"]["derived"],
        [
            "primary_subject",
            "secondary_subject",
            "primary_planets_data",
            "primary_houses_data",
            "secondary_planets_data",
            "secondary_houses_data",
            "house_comparison",
            "relationship_score",
            "advanced_summary",
            "return_type",
            "return_year",
        ],
    )
    metadata["field_roles"]["advanced_context"] = [
        "time_context",
        "return_context",
    ]
    return {
        "chart_data": chart_dump,
        "primary_subject": _build_subject_snapshot(natal_dump),
        "secondary_subject": _build_subject_snapshot(return_dump),
        "primary_planets_data": _build_planets_data(natal_dump),
        "primary_houses_data": _build_houses_data(natal_dump),
        "secondary_planets_data": _build_planets_data(return_dump),
        "secondary_houses_data": _build_houses_data(return_dump),
        "aspects_data": _build_aspects_data(chart_dump),
        "house_comparison": chart_dump.get("house_comparison"),
        "relationship_score": chart_dump.get("relationship_score"),
        "advanced_mode": "return",
        "advanced_summary": _build_advanced_summary(
            "return",
            chart_dump,
            natal_dump,
            return_dump,
            return_type=return_type,
            return_year=return_year,
        ),
        "route_mode": normalized_route_mode,
        "engine_info": {
            "engine_name": ENGINE_NAME,
            "engine_version": metadata["engine_version"],
            "schema_version": SCHEMA_VERSION,
            "chart_kind": "return",
            "advanced_mode": "return",
        },
        "metadata": metadata,
        "generated_at": datetime.utcnow().isoformat() + "Z",
    }


def _build_metadata(
    route_mode: str,
    *,
    chart_kind: str = "natal",
    advanced_mode: str | None = None,
    advanced_context: dict[str, Any] | None = None,
) -> dict[str, Any]:
    metadata = {
        "schema_version": SCHEMA_VERSION,
        "engine_name": ENGINE_NAME,
        "engine_version": _resolve_engine_version(),
        "chart_kind": chart_kind,
        "route_context": {
            "route_mode": route_mode,
            "route_preset": route_mode,
            "source": "display_only",
        },
        "field_roles": {
            "canonical": [
                "birthday",
                "birth_time",
                "birth_place",
                "birth_lat",
                "birth_lng",
                "tz_str",
            ],
            "derived": [
                "chart_data",
                "planets_data",
                "houses_data",
                "aspects_data",
                "generated_at",
            ],
            "display_only": ["route_mode"],
        },
    }
    if advanced_mode is not None and advanced_context is not None:
        metadata["advanced_context"] = advanced_context
        metadata["field_roles"]["advanced_context"] = [
            "pair_context",
            "comparison_context",
            "time_context",
            "return_context",
        ]
    return metadata


def _resolve_engine_version() -> str:
    try:
        return version("kerykeion")
    except PackageNotFoundError:
        return "unknown"


def _normalize_route_mode(value: str | None) -> str:
    normalized = (value or "standard").strip().lower()
    if normalized in {"standard", "classical", "modern"}:
        return normalized
    return "standard"


def _normalize_pair_mode(value: str | None) -> str:
    normalized = (value or "synastry").strip().lower()
    if normalized in {"synastry", "comparison"}:
        return normalized
    return "synastry"


def _build_subject_from_dict(data: dict[str, Any]) -> Any:
    return _build_subject(
        name=str(data.get("name") or "EliteSync"),
        birthday=str(data.get("birthday") or ""),
        birth_time=str(data.get("birth_time") or ""),
        birth_place=data.get("birth_place"),
        birth_lat=data.get("birth_lat"),
        birth_lng=data.get("birth_lng"),
        tz_str=data.get("tz_str"),
        nation=str(data.get("nation") or "CN"),
    )


def _build_subject(
    *,
    name: str,
    birthday: str,
    birth_time: str,
    birth_place: str | None,
    birth_lat: float | None,
    birth_lng: float | None,
    tz_str: str | None,
    nation: str = "CN",
) -> Any:
    year, month, day = _parse_date(birthday)
    hour, minute = _parse_time(birth_time)
    city = (birth_place or "").strip() or None
    return AstrologicalSubjectFactory.from_birth_data(
        name=name.strip() or "EliteSync",
        year=year,
        month=month,
        day=day,
        hour=hour,
        minute=minute,
        city=city,
        nation=(nation or "CN").strip() or "CN",
        lng=birth_lng,
        lat=birth_lat,
        tz_str=(tz_str or "Asia/Shanghai").strip() or "Asia/Shanghai",
        online=False,
    )


def _build_subject_snapshot(subject_dump: dict[str, Any]) -> dict[str, Any]:
    return {
        "name": subject_dump.get("name"),
        "city": subject_dump.get("city"),
        "nation": subject_dump.get("nation"),
        "lng": subject_dump.get("lng"),
        "lat": subject_dump.get("lat"),
        "tz_str": subject_dump.get("tz_str"),
        "iso_formatted_local_datetime": subject_dump.get("iso_formatted_local_datetime"),
        "iso_formatted_utc_datetime": subject_dump.get("iso_formatted_utc_datetime"),
        "zodiac_type": subject_dump.get("zodiac_type"),
        "houses_system_name": subject_dump.get("houses_system_name"),
        "perspective_type": subject_dump.get("perspective_type"),
        "active_points": subject_dump.get("active_points"),
        "year": subject_dump.get("year"),
        "month": subject_dump.get("month"),
        "day": subject_dump.get("day"),
        "hour": subject_dump.get("hour"),
        "minute": subject_dump.get("minute"),
    }


def _build_advanced_summary(
    advanced_mode: str,
    chart_dump: dict[str, Any],
    primary_dump: dict[str, Any],
    secondary_dump: dict[str, Any],
    *,
    pair_mode: str | None = None,
    return_type: str | None = None,
    return_year: int | None = None,
) -> dict[str, Any]:
    aspects = chart_dump.get("aspects")
    relationship_score = chart_dump.get("relationship_score")
    summary: dict[str, Any] = {
        "advanced_mode": advanced_mode,
        "chart_type": chart_dump.get("chart_type"),
        "primary_name": primary_dump.get("name"),
        "secondary_name": secondary_dump.get("name"),
        "aspects_count": len(aspects) if isinstance(aspects, list) else 0,
        "house_comparison_present": bool(chart_dump.get("house_comparison")),
        "relationship_score_present": bool(relationship_score),
    }
    if pair_mode is not None:
        summary["pair_mode"] = pair_mode
    if return_type is not None:
        summary["return_type"] = return_type
    if return_year is not None:
        summary["return_year"] = return_year
    if isinstance(relationship_score, dict):
        summary["relationship_score_value"] = relationship_score.get("score_value")
        summary["relationship_score_description"] = relationship_score.get("score_description")
    return summary


def _merge_unique_fields(base: list[str], additions: list[str]) -> list[str]:
    seen = set()
    merged: list[str] = []
    for value in [*base, *additions]:
        if value in seen:
            continue
        seen.add(value)
        merged.append(value)
    return merged


def _build_planets_data(subject_dump: dict[str, Any]) -> list[dict[str, Any]]:
    planet_keys = [
        "sun",
        "moon",
        "mercury",
        "venus",
        "mars",
        "jupiter",
        "saturn",
        "uranus",
        "neptune",
        "pluto",
        "ascendant",
        "descendant",
        "medium_coeli",
        "imum_coeli",
        "chiron",
        "earth",
        "mean_north_lunar_node",
        "true_north_lunar_node",
        "mean_south_lunar_node",
        "true_south_lunar_node",
    ]
    result: list[dict[str, Any]] = []
    for key in planet_keys:
        row = subject_dump.get(key)
        if not isinstance(row, dict):
            continue
        result.append({
            "key": key,
            "name": row.get("name") or key,
            "sign": row.get("sign"),
            "house": row.get("house"),
            "position": row.get("position"),
            "retrograde": row.get("retrograde"),
            "element": row.get("element"),
            "quality": row.get("quality"),
            "point_type": row.get("point_type"),
        })
    return result


def _build_houses_data(subject_dump: dict[str, Any]) -> list[dict[str, Any]]:
    house_keys = [
        "first_house",
        "second_house",
        "third_house",
        "fourth_house",
        "fifth_house",
        "sixth_house",
        "seventh_house",
        "eighth_house",
        "ninth_house",
        "tenth_house",
        "eleventh_house",
        "twelfth_house",
    ]
    result: list[dict[str, Any]] = []
    for index, key in enumerate(house_keys, start=1):
        row = subject_dump.get(key)
        if not isinstance(row, dict):
            continue
        result.append({
            "index": index,
            "key": key,
            "name": row.get("name") or f"{index}宫",
            "sign": row.get("sign"),
            "house": row.get("house"),
            "position": row.get("position"),
            "retrograde": row.get("retrograde"),
            "element": row.get("element"),
            "quality": row.get("quality"),
            "point_type": row.get("point_type"),
        })
    return result


def _build_aspects_data(chart_dump: dict[str, Any]) -> list[dict[str, Any]]:
    aspects = chart_dump.get("aspects")
    if not isinstance(aspects, list):
        return []
    result: list[dict[str, Any]] = []
    for row in aspects:
        if not isinstance(row, dict):
            continue
        result.append({
            "p1_name": row.get("p1_name"),
            "p1_owner": row.get("p1_owner"),
            "p2_name": row.get("p2_name"),
            "p2_owner": row.get("p2_owner"),
            "aspect": row.get("aspect"),
            "orbit": row.get("orbit"),
            "aspect_degrees": row.get("aspect_degrees"),
            "diff": row.get("diff"),
            "aspect_movement": row.get("aspect_movement"),
        })
    return result


def _parse_date(value: str) -> tuple[int, int, int]:
    parsed = datetime.strptime(value, "%Y-%m-%d")
    return parsed.year, parsed.month, parsed.day


def _parse_time(value: str) -> tuple[int, int]:
    parsed = datetime.strptime(value, "%H:%M")
    return parsed.hour, parsed.minute


def serialize_chart_json(payload: dict[str, Any]) -> str:
    return json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
