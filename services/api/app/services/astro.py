import json
from datetime import datetime
from typing import Any

from kerykeion import AstrologicalSubjectFactory, ChartDataFactory, ChartDrawer


def build_natal_chart_payload(
    *,
    name: str,
    birthday: str,
    birth_time: str,
    birth_place: str | None,
    birth_lat: float | None,
    birth_lng: float | None,
    tz_str: str | None,
) -> dict[str, Any]:
    year, month, day = _parse_date(birthday)
    hour, minute = _parse_time(birth_time)
    city = (birth_place or "").strip() or None
    subject = AstrologicalSubjectFactory.from_birth_data(
        name=name.strip() or "EliteSync",
        year=year,
        month=month,
        day=day,
        hour=hour,
        minute=minute,
        city=city,
        nation="CN",
        lng=birth_lng,
        lat=birth_lat,
        tz_str=(tz_str or "Asia/Shanghai").strip() or "Asia/Shanghai",
        online=False,
    )
    chart_data = ChartDataFactory.create_natal_chart_data(subject)
    # Use the wheel-only renderer so the client receives the circular chart as
    # the primary visual. This keeps Flutter from shrinking the wheel to fit
    # the aspect table and is still compatible with downstream SVG cleanup.
    svg = ChartDrawer(
        chart_data,
        external_view=True,
        show_aspect_icons=False,
        padding=8,
    ).generate_wheel_only_svg_string(remove_css_variables=True)
    chart_dump = chart_data.model_dump()
    subject_dump = chart_dump.get("subject", {}) if isinstance(chart_dump, dict) else {}
    return {
        "natal_chart_svg": svg,
        "chart_data": chart_dump,
        "planets_data": _build_planets_data(subject_dump),
        "houses_data": _build_houses_data(subject_dump),
        "aspects_data": _build_aspects_data(chart_dump),
        "generated_at": datetime.utcnow().isoformat() + "Z",
    }


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
