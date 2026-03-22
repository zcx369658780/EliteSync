import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QB_DIR = ROOT / "question_bank"

SCHEMA_VERSION = "2.0"

QUESTIONS = [
    {
        "question_id": "Q_REL_V2_001",
        "category": "communication",
        "subtopic": "delayed_reply",
        "question_text": "你连续两次发出邀请，对方回复都很慢且没有解释。你更可能怎么做？",
        "measured_dimensions": ["communication_clarity", "attachment_security", "rejection_resilience", "autonomy_boundary"],
        "options": [
            "直接问清楚，同时给对方解释空间",
            "先降低联系频率，观察对方是否会主动",
            "立刻追问是不是对我没兴趣",
            "发一句轻松的话，把选择权交给对方",
        ],
    },
    {
        "question_id": "Q_REL_V2_002",
        "category": "lifestyle",
        "subtopic": "last_minute_cancellation",
        "question_text": "约会当天对方临时取消，说工作突发状况。你通常会怎么处理？",
        "measured_dimensions": ["emotional_regulation", "planning_reliability", "empathy_responsiveness", "autonomy_boundary", "conflict_repair"],
        "options": [
            "先确认对方情况，再一起改时间",
            "嘴上说没事，但心里会记一笔",
            "明确表达影响，要求下次提前沟通",
            "直接结束这次安排，后续再看",
        ],
    },
    {
        "question_id": "Q_REL_V2_003",
        "category": "family",
        "subtopic": "family_pressure",
        "question_text": "对方因家庭压力情绪崩溃。你的第一反应更接近哪一种？",
        "measured_dimensions": ["empathy_responsiveness", "emotional_regulation", "attachment_security", "intimacy_disclosure", "conflict_repair"],
        "options": [
            "先安抚情绪，再问是想被安慰还是想解决",
            "先给很多建议，希望尽快走出情绪",
            "安静陪伴，但不主动深聊细节",
            "怕说错话，先回避这个话题",
        ],
    },
    {
        "question_id": "Q_REL_V2_004",
        "category": "relationship_goals",
        "subtopic": "contact_with_ex",
        "question_text": "前任在你生日发来祝福。你更可能如何处理？",
        "measured_dimensions": ["attachment_security", "communication_clarity", "autonomy_boundary", "commitment_readiness"],
        "options": [
            "主动告知正在接触的人，并说明处理方式",
            "礼貌回复后结束，不专门提这件事",
            "只要不暧昧，就不主动告诉对方",
            "不回复并一次性立清边界",
        ],
    },
    {
        "question_id": "Q_REL_V2_005",
        "category": "lifestyle",
        "subtopic": "tired_weekend",
        "question_text": "工作一周后很累，但周末有期待已久的约会。你会怎么安排？",
        "measured_dimensions": ["social_initiative", "openness_exploration", "emotional_regulation"],
        "options": [
            "选安静但有新鲜感的地点，缩短时长",
            "诚实说状态不好，改约下周",
            "照常见面，但让对方主导安排",
            "直接取消，不想解释太多",
        ],
    },
    {
        "question_id": "Q_REL_V2_006",
        "category": "lifestyle",
        "subtopic": "trip_budget",
        "question_text": "两人计划旅行时消费观差异很大。你更可能怎么处理？",
        "measured_dimensions": ["planning_reliability", "reciprocity_investment", "autonomy_boundary", "openness_exploration", "commitment_readiness"],
        "options": [
            "先定预算上限，再一起删减项目",
            "旅行难得，愿意多花一点换体验",
            "倾向各花各的，不强行统一标准",
            "若长期谈不拢，会重新评估关系",
        ],
    },
    {
        "question_id": "Q_REL_V2_007",
        "category": "relationship_goals",
        "subtopic": "city_choice",
        "question_text": "你们相处不错，但工作机会让双方可能去不同城市。你更可能怎么做？",
        "measured_dimensions": ["commitment_readiness", "planning_reliability", "autonomy_boundary", "attachment_security"],
        "options": [
            "把职业和生活成本摊开，先做过渡方案",
            "优先机会更稀缺的一方",
            "先各自发展，不急着做大调整",
            "优先保住自己的生活节奏",
        ],
    },
    {
        "question_id": "Q_REL_V2_008",
        "category": "social_energy",
        "subtopic": "meet_close_friends",
        "question_text": "第一次把对方介绍给你最熟的朋友时，你通常会怎么做？",
        "measured_dimensions": ["social_initiative", "intimacy_disclosure", "attachment_security"],
        "options": [
            "提前做介绍，主动帮双方接话",
            "顺其自然，不刻意安排流程",
            "先观察对方状态，再决定介绍深度",
            "尽量把不同圈层分开，不混在一起",
        ],
    },
    {
        "question_id": "Q_REL_V2_009",
        "category": "communication",
        "subtopic": "social_media_boundary",
        "question_text": "对方希望公开你们的关系到社交平台。你的第一反应更接近哪一种？",
        "measured_dimensions": ["autonomy_boundary", "communication_clarity", "attachment_security", "commitment_readiness"],
        "options": [
            "先聊清彼此需求，再决定公开范围",
            "可配合公开，但不会太主动",
            "感情是私事，不希望被平台定义",
            "若对方执着公开，会怀疑关系稳定性",
        ],
    },
    {
        "question_id": "Q_REL_V2_010",
        "category": "communication",
        "subtopic": "shutdown_after_argument",
        "question_text": "争执后对方沉默数小时。你更可能怎么处理？",
        "measured_dimensions": ["emotional_regulation", "conflict_repair", "attachment_security", "communication_clarity", "rejection_resilience"],
        "options": [
            "给冷静时间并约定具体沟通时间",
            "持续发消息，直到对方回应",
            "既然沉默，我也不再主动解决",
            "先整理感受，再发核心问题",
        ],
    },
    {
        "question_id": "Q_REL_V2_011",
        "category": "intimacy",
        "subtopic": "embarrassing_story",
        "question_text": "对方问你是否有很少对外提及的尴尬经历。你通常会怎么回应？",
        "measured_dimensions": ["intimacy_disclosure", "attachment_security", "rejection_resilience"],
        "options": [
            "讲一件真实但边界安全的经历",
            "会说，但用玩笑带过去",
            "先保留，等更熟再讲",
            "转移话题，避免这类试探",
        ],
    },
    {
        "question_id": "Q_REL_V2_012",
        "category": "lifestyle",
        "subtopic": "travel_delay",
        "question_text": "出行遇到突发延误，计划被打乱。你通常更接近哪种反应？",
        "measured_dimensions": ["emotional_regulation", "planning_reliability", "openness_exploration", "conflict_repair"],
        "options": [
            "列出备选方案后再决策",
            "把意外当新体验继续玩",
            "会烦躁，但尽量不甩情绪",
            "若是对方失误，会当场表达不满",
        ],
    },
    {
        "question_id": "Q_REL_V2_013",
        "category": "family",
        "subtopic": "care_when_ill",
        "question_text": "对方生病而你也很忙时，你通常如何安排投入？",
        "measured_dimensions": ["reciprocity_investment", "empathy_responsiveness", "planning_reliability", "autonomy_boundary"],
        "options": [
            "调整安排，保证必要照顾和同步",
            "会关心，也会说明自己能力边界",
            "更多提供方法和资源，不投入太多陪伴",
            "关系未稳定前，不会明显打乱节奏",
        ],
    },
    {
        "question_id": "Q_REL_V2_014",
        "category": "relationship_goals",
        "subtopic": "define_relationship",
        "question_text": "对方提出想把关系说清楚。你通常会怎么回应？",
        "measured_dimensions": ["commitment_readiness", "communication_clarity", "attachment_security", "autonomy_boundary"],
        "options": [
            "愿意谈，在稳定后明确关系",
            "先问清期待，再决定是否独占",
            "觉得现在太早，更看重自然相处",
            "对推进太快会本能后退",
        ],
    },
    {
        "question_id": "Q_REL_V2_015",
        "category": "social_energy",
        "subtopic": "party_pacing",
        "question_text": "聚会时你和对方社交状态不一致。你通常如何处理节奏？",
        "measured_dimensions": ["social_initiative", "empathy_responsiveness", "autonomy_boundary"],
        "options": [
            "先陪对方适应，再决定一起或分开行动",
            "主动带节奏，不让场子冷下来",
            "给彼此自由，不要求全程绑定",
            "若对方明显不适，会提前离场",
        ],
    },
    {
        "question_id": "Q_REL_V2_016",
        "category": "communication",
        "subtopic": "forgotten_date",
        "question_text": "对方忘了一个对你很重要的日子。你通常会怎么反应？",
        "measured_dimensions": ["conflict_repair", "emotional_regulation", "planning_reliability", "attachment_security"],
        "options": [
            "直接表达失望，并给补救机会",
            "口头没事，实际会降低期待",
            "先看对方平时整体是否用心",
            "若反复发生，会视作重视度不足",
        ],
    },
    {
        "question_id": "Q_REL_V2_017",
        "category": "communication",
        "subtopic": "daily_checkin",
        "question_text": "稳定联系阶段，你对每天报备式联系的态度更接近哪一种？",
        "measured_dimensions": ["intimacy_disclosure", "communication_clarity", "autonomy_boundary", "attachment_security"],
        "options": [
            "喜欢简短稳定的日常同步",
            "想到什么说什么，不想任务化",
            "可配合，但不希望规则太细",
            "频繁报备会让我有被管理感",
        ],
    },
    {
        "question_id": "Q_REL_V2_018",
        "category": "family",
        "subtopic": "supporting_parents_financially",
        "question_text": "若一方需长期支持原生家庭经济，这会影响共同生活。你更可能怎么处理？",
        "measured_dimensions": ["reciprocity_investment", "planning_reliability", "autonomy_boundary", "empathy_responsiveness", "commitment_readiness"],
        "options": [
            "先讲清家庭责任，再调整共同计划",
            "可以理解，但不默认共同承担",
            "若长期挤压生活，会谨慎推进关系",
            "先一起扛住当前压力，再谈长期",
        ],
    },
    {
        "question_id": "Q_REL_V2_019",
        "category": "communication",
        "subtopic": "feedback_on_habit",
        "question_text": "你发现对方某个习惯已影响相处感受。你更可能怎么反馈？",
        "measured_dimensions": ["communication_clarity", "empathy_responsiveness", "conflict_repair", "rejection_resilience"],
        "options": [
            "用具体场景说明影响，并给替代建议",
            "会提醒，但语气尽量温和",
            "先忍着，实在受不了再说",
            "不想改造别人，合不来就拉开距离",
        ],
    },
    {
        "question_id": "Q_REL_V2_020",
        "category": "relationship_goals",
        "subtopic": "children_timeline",
        "question_text": "聊到是否要孩子和时间线时，你通常更接近哪种态度？",
        "measured_dimensions": ["commitment_readiness", "planning_reliability", "attachment_security", "autonomy_boundary", "communication_clarity"],
        "options": [
            "先把时间线、经济和分工谈清楚",
            "先对齐方向，但不想过早锁死",
            "若尚未想好，会如实说明不承诺",
            "一聊到这个话题就想回避",
        ],
    },
]

BASE = [
    [0.72, 0.43, 0.18, -0.27, 0.08],
    [0.24, 0.67, -0.31, 0.12, -0.46],
    [-0.16, 0.35, 0.74, -0.28, 0.11],
    [-0.52, -0.19, 0.22, 0.61, -0.33],
]


def jitter(seed: str, idx: int) -> float:
    h = hashlib.sha1(f"{seed}:{idx}".encode()).digest()
    raw = int(h[0]) / 255.0
    return round((raw - 0.5) * 0.18, 2)


def unique_in_option(vals):
    out = []
    seen = set()
    for i, v in enumerate(vals):
        x = round(v, 2)
        while x in seen:
            x = round(x + (0.01 if i % 2 == 0 else -0.01), 2)
        seen.add(x)
        out.append(x)
    return out


def weight_map(qid: str, dims, option_index: int):
    vals = []
    for i, _ in enumerate(dims):
        v = BASE[option_index][i] + jitter(f"{qid}:{option_index}", i)
        v = max(-0.85, min(0.85, v))
        vals.append(v)
    vals = unique_in_option(vals)
    return {d: vals[i] for i, d in enumerate(dims)}


def build_question(raw, bank):
    dims = raw["measured_dimensions"]
    options = []
    for idx, label in enumerate(raw["options"]):
        options.append(
            {
                "option_id": ["A", "B", "C", "D"][idx],
                "label": {"zh": label, "en": ""},
                "dimension_weights": weight_map(raw["question_id"], dims, idx),
                "score": [1.0, 0.6, 0.2, -0.2][idx],
            }
        )

    return {
        "question_id": raw["question_id"],
        "category": raw["category"],
        "subtopic": raw["subtopic"],
        "question_text": {"zh": raw["question_text"], "en": ""},
        "answer_type": "single_choice",
        "acceptable_answer_logic": "single_select",
        "measured_dimensions": dims,
        "options": options,
        "importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
        "sensitivity_level": "low",
        "recommended_bank": bank,
        "tags": [raw["category"], raw["subtopic"], "v2", "dating", "compatibility"],
        "active": True,
        "version": 2,
        "quality_tier": "high",
        "quality_meta": {"reason": "v2_multi_dim_unique_weights", "quality_tag": "pass"},
        "quality_tag": "pass",
    }


def validate_question(q):
    dims = q["measured_dimensions"]
    assert 2 <= len(dims) <= 5, q["question_id"]
    assert len(q["options"]) == 4, q["question_id"]

    vectors = []
    all_values = []
    for opt in q["options"]:
        w = opt["dimension_weights"]
        assert set(w.keys()) == set(dims), q["question_id"]
        vals = [round(float(w[d]), 3) for d in dims]
        assert len(set(vals)) == len(vals), q["question_id"]
        vectors.append(tuple(vals))
        all_values.extend(vals)

    assert len(set(vectors)) == len(vectors), q["question_id"]
    assert any(v > 0 for v in all_values) and any(v < 0 for v in all_values), q["question_id"]


def make_payload(title_zh, bank_id, items):
    cats = sorted({q["category"] for q in items})
    return {
        "schema_version": SCHEMA_VERSION,
        "question_bank_id": bank_id,
        "title": {"zh": title_zh, "en": title_zh},
        "description": {"zh": "V2 多维联合测量题库", "en": "V2 multi-dimensional bank"},
        "categories": cats,
        "default_importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
        "questions": items,
    }


def main():
    QB_DIR.mkdir(parents=True, exist_ok=True)

    banks = {
        "core": [],
        "extended": [],
        "research": [],
    }

    for i, raw in enumerate(QUESTIONS):
        if i < 8:
            bank = "core"
        elif i < 14:
            bank = "extended"
        else:
            bank = "research"

        q = build_question(raw, bank)
        validate_question(q)
        banks[bank].append(q)

    core_payload = make_payload("慢约会题库 core v2", "question_bank_core_v1", banks["core"])
    ext_payload = make_payload("慢约会题库 extended v2", "question_bank_extended_v1", banks["extended"])
    res_payload = make_payload("慢约会题库 research v2", "question_bank_research_v1", banks["research"])

    (QB_DIR / "question_bank_core_v1.json").write_text(json.dumps(core_payload, ensure_ascii=False, indent=2), encoding="utf-8")
    (QB_DIR / "question_bank_extended_v1.json").write_text(json.dumps(ext_payload, ensure_ascii=False, indent=2), encoding="utf-8")
    (QB_DIR / "question_bank_research_v1.json").write_text(json.dumps(res_payload, ensure_ascii=False, indent=2), encoding="utf-8")

    merged = {
        "schema_version": SCHEMA_VERSION,
        "question_bank_id": "dating_question_bank_v_1",
        "title": {"zh": "慢约会题库 v2", "en": "SlowDating Question Bank v2"},
        "description": {"zh": "V2 金标准 20 题", "en": "V2 20 questions"},
        "categories": sorted({q["category"] for q in banks["core"] + banks["extended"] + banks["research"]}),
        "default_importance_mapping": {"0": 0.0, "1": 0.33, "2": 0.66, "3": 1.0},
        "questions": banks["core"] + banks["extended"] + banks["research"],
    }
    (QB_DIR / "dating_question_bank_v_1.json").write_text(json.dumps(merged, ensure_ascii=False, indent=2), encoding="utf-8")

    print("generated", sum(len(v) for v in banks.values()), "questions")


if __name__ == "__main__":
    main()
