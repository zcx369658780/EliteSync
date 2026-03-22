#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QB_DIR = ROOT / "question_bank"
FILES = [
    QB_DIR / "question_bank_core_v1.json",
    QB_DIR / "question_bank_extended_v1.json",
    QB_DIR / "question_bank_research_v1.json",
    QB_DIR / "dating_question_bank_v_1.json",
]

NEUTRAL_TOKENS_ZH = [
    "视具体情境而定",
    "看情况",
    "都可以",
    "不确定",
]
NEUTRAL_TOKENS_EN = [
    "it depends",
    "not sure",
    "either is fine",
]


def has_neutral_option(options: list[dict]) -> bool:
    for opt in options:
        label = opt.get("label") or {}
        zh = str(label.get("zh") or "").lower()
        en = str(label.get("en") or "").lower()
        if any(tok in zh for tok in NEUTRAL_TOKENS_ZH):
            return True
        if any(tok in en for tok in NEUTRAL_TOKENS_EN):
            return True
    return False


def score_spread(options: list[dict]) -> float:
    scores = []
    for opt in options:
        try:
            scores.append(float(opt.get("score", 0)))
        except (TypeError, ValueError):
            continue
    if not scores:
        return 0.0
    return max(scores) - min(scores)


def classify_question(q: dict) -> tuple[str, str, str]:
    options = q.get("options") or []
    option_count = len(options)
    spread = score_spread(options)
    neutral = has_neutral_option(options)

    if option_count <= 1:
        return ("low", "too_few_options", "low_drop")
    if neutral:
        return ("low", "neutral_option_present", "low_keep")
    if spread < 0.25:
        return ("low", "low_discrimination", "low_drop")
    if option_count in (2, 4) and spread >= 0.65:
        return ("high", "high_discrimination", "pass")
    if spread >= 0.35:
        return ("normal", "standard_discrimination", "pass")
    return ("low", "borderline_discrimination", "low_keep")


def process_file(path: Path):
    if not path.exists():
        return (path.name, 0, 0, 0, 0)

    payload = json.loads(path.read_text(encoding="utf-8"))
    questions = payload.get("questions") or []
    high = normal = low = 0
    pass_count = low_keep = low_drop = 0

    for q in questions:
        tier, reason, quality_tag = classify_question(q)
        q["quality_tier"] = tier
        q["quality_tag"] = quality_tag
        q["quality_meta"] = {"reason": reason, "quality_tag": quality_tag}
        if tier == "high":
            high += 1
        elif tier == "normal":
            normal += 1
        else:
            low += 1
        if quality_tag == "pass":
            pass_count += 1
        elif quality_tag == "low_keep":
            low_keep += 1
        else:
            low_drop += 1

    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return (path.name, len(questions), high, normal, low, pass_count, low_keep, low_drop)


def main():
    t_q = t_h = t_n = t_l = 0
    t_pass = t_keep = t_drop = 0
    for f in FILES:
        name, count, high, normal, low, pass_count, low_keep, low_drop = process_file(f)
        t_q += count
        t_h += high
        t_n += normal
        t_l += low
        t_pass += pass_count
        t_keep += low_keep
        t_drop += low_drop
        print(
            f"{name}: total={count}, high={high}, normal={normal}, low={low}, "
            f"pass={pass_count}, low_keep={low_keep}, low_drop={low_drop}"
        )
    print(
        f"ALL: total={t_q}, high={t_h}, normal={t_n}, low={t_l}, "
        f"pass={t_pass}, low_keep={t_keep}, low_drop={t_drop}"
    )


if __name__ == "__main__":
    main()
