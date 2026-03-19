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


def classify_question(q: dict) -> tuple[str, str]:
    options = q.get("options") or []
    option_count = len(options)
    spread = score_spread(options)
    neutral = has_neutral_option(options)

    if option_count <= 1:
        return ("low", "too_few_options")
    if neutral or spread < 0.25:
        return ("low", "low_discrimination")
    if option_count in (2, 4) and spread >= 0.6:
        return ("high", "high_discrimination")
    return ("normal", "standard_discrimination")


def process_file(path: Path):
    if not path.exists():
        return (path.name, 0, 0, 0, 0)

    payload = json.loads(path.read_text(encoding="utf-8"))
    questions = payload.get("questions") or []
    high = normal = low = 0

    for q in questions:
        tier, reason = classify_question(q)
        q["quality_tier"] = tier
        q["quality_meta"] = {"reason": reason}
        if tier == "high":
            high += 1
        elif tier == "normal":
            normal += 1
        else:
            low += 1

    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return (path.name, len(questions), high, normal, low)


def main():
    t_q = t_h = t_n = t_l = 0
    for f in FILES:
        name, count, high, normal, low = process_file(f)
        t_q += count
        t_h += high
        t_n += normal
        t_l += low
        print(f"{name}: total={count}, high={high}, normal={normal}, low={low}")
    print(f"ALL: total={t_q}, high={t_h}, normal={t_n}, low={t_l}")


if __name__ == "__main__":
    main()
