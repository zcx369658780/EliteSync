#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QB_DIR = ROOT / "question_bank"
FILES = [
    QB_DIR / "question_bank_core_v1.json",
    QB_DIR / "question_bank_extended_v1.json",
    QB_DIR / "question_bank_research_v1.json",
    QB_DIR / "dating_question_bank_v_1.json",
]

ZH_PREFIX_PATTERNS = [
    (re.compile(r"^\s*明显更接近[:：]\s*"), ("strongly_closer", "明显更接近", "Strongly closer")),
    (re.compile(r"^\s*略偏向[:：]\s*"), ("slightly_closer", "略偏向", "Slightly closer")),
    (re.compile(r"^\s*更接近[:：]\s*"), ("closer", "更接近", "Closer to")),
]

EN_PREFIX_PATTERNS = [
    (re.compile(r"^\s*Strongly closer to:\s*", flags=re.IGNORECASE), ("strongly_closer", "明显更接近", "Strongly closer")),
    (re.compile(r"^\s*Slightly closer to:\s*", flags=re.IGNORECASE), ("slightly_closer", "略偏向", "Slightly closer")),
    (re.compile(r"^\s*Closer to:\s*", flags=re.IGNORECASE), ("closer", "更接近", "Closer to")),
]

ZH_SUFFIX_RE = re.compile(r"\s*[（(]\s*偏向\s*[A-Da-d]\s*[)）]\s*$")
EN_SUFFIX_RE = re.compile(r"\s*[（(]\s*leans?\s*[A-Da-d]\s*[)）]\s*$", flags=re.IGNORECASE)


def split_label(text: str, lang: str):
    src = (text or "").strip()
    if src == "":
        return src, None

    patterns = ZH_PREFIX_PATTERNS if lang == "zh" else EN_PREFIX_PATTERNS
    suffix_re = ZH_SUFFIX_RE if lang == "zh" else EN_SUFFIX_RE

    code = None
    standard_zh = None
    standard_en = None
    cleaned = src

    for regex, (c, s_zh, s_en) in patterns:
        if regex.search(cleaned):
            cleaned = regex.sub("", cleaned).strip()
            code = c
            standard_zh = s_zh
            standard_en = s_en
            break

    cleaned = suffix_re.sub("", cleaned).strip()

    if code is None:
        return cleaned, None

    return cleaned, {
        "code": code,
        "zh": standard_zh,
        "en": standard_en,
    }


def process_file(path: Path):
    if not path.exists():
        return (path.name, 0, 0)

    data = json.loads(path.read_text(encoding="utf-8"))
    questions = data.get("questions") or []
    changed_options = 0

    for q in questions:
        options = q.get("options") or []
        for opt in options:
            label = opt.get("label") or {}
            zh = str(label.get("zh") or "")
            en = str(label.get("en") or "")

            zh_clean, zh_std = split_label(zh, "zh")
            en_clean, en_std = split_label(en, "en")

            changed = (zh_clean != zh) or (en_clean != en)
            if not changed:
                continue

            label["zh"] = zh_clean
            label["en"] = en_clean
            opt["label"] = label

            std = opt.get("evaluation_standard") or {}
            picked = zh_std or en_std
            if picked:
                std["code"] = picked.get("code")
                std["zh"] = picked.get("zh")
                std["en"] = picked.get("en")
                opt["evaluation_standard"] = std

            changed_options += 1

    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return (path.name, len(questions), changed_options)


def main():
    total_questions = 0
    total_changed_options = 0
    for f in FILES:
        name, q_count, changed_opts = process_file(f)
        total_questions += q_count
        total_changed_options += changed_opts
        print(f"{name}: questions={q_count}, changed_options={changed_opts}")
    print(f"ALL: questions={total_questions}, changed_options={total_changed_options}")


if __name__ == "__main__":
    main()
