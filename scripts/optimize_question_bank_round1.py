#!/usr/bin/env python3
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QB_DIR = ROOT / "question_bank"
FILES = [
    QB_DIR / "question_bank_core_v1.json",
    QB_DIR / "question_bank_extended_v1.json",
    QB_DIR / "question_bank_research_v1.json",
]

SUBTOPIC_POLES = {
    "commitment": ("尽早明确关系并认真投入", "先观察磨合，再决定投入程度"),
    "trust": ("倾向于高透明度和及时沟通", "倾向于慢慢建立信任、保留空间"),
    "life_priorities": ("关系与共同生活优先", "个人发展与独立节奏优先"),
    "money_values": ("消费与储蓄尽量协同", "保留各自财务习惯与自主度"),
    "loyalty": ("边界清晰、排他性更强", "边界可协商、社交更开放"),
    "integrity": ("更看重言行一致和承诺兑现", "更看重当下感受和灵活调整"),
    "goal_type": ("以长期稳定关系为目标", "以自然相处和阶段体验为目标"),
    "pace": ("推进节奏可以更明确一些", "更适合慢节奏、逐步深入"),
    "exclusivity": ("较早建立专一关系", "先开放了解，再决定是否专一"),
    "future_planning": ("倾向尽早讨论未来计划", "倾向先享受当下再谈未来"),
    "seriousness": ("从一开始就认真筛选", "先轻松相处，合适再升级"),
    "dating_intent": ("目的明确，重匹配效率", "重过程体验，保留探索空间"),
    "schedule": ("作息规律、计划性更强", "作息灵活、顺应状态变化"),
    "fitness": ("愿意固定投入运动和健康管理", "保持适度即可，不强求规律"),
    "travel_style": ("偏好有计划、有节奏的旅行", "偏好随性、临场决定的旅行"),
    "drinking": ("更偏向克制或少饮", "更偏向社交场景下适度饮酒"),
    "spending_style": ("偏理性预算与长期规划", "偏体验消费与当下满足"),
    "work_life_balance": ("更强调生活优先和留白", "更强调事业投入和成长机会"),
    "social_frequency": ("高频社交更有能量", "低频社交、深度连接更舒适"),
    "alone_time": ("需要较多独处恢复", "更习惯在陪伴中恢复"),
    "gatherings": ("更喜欢小范围深聊", "更喜欢多人活动与热闹氛围"),
    "partner_rhythm": ("希望两人节奏高度同步", "允许节奏差异、保留弹性"),
    "weekend_energy": ("周末偏休整与充电", "周末偏探索与外出"),
    "crowd_preference": ("偏安静熟悉环境", "偏新鲜人群与公开场景"),
    "conflict": ("倾向及时直面问题", "倾向先冷静再沟通"),
    "texting": ("偏高频即时回复", "偏低频但完整回复"),
    "affection_expression": ("偏直接表达爱意", "偏用行动与细节表达"),
    "date_pacing": ("愿意更快推进关系节点", "希望慢慢确认再推进"),
    "feedback_style": ("偏直接反馈、问题导向", "偏温和反馈、情绪照顾优先"),
    "emotional_expression": ("愿意外显情绪并讨论", "倾向内化整理后再表达"),
    "children": ("偏积极考虑生育计划", "偏谨慎或暂不考虑生育"),
    "marriage_view": ("倾向将婚姻作为重要目标", "倾向先看关系质量再谈婚姻"),
    "family_boundary": ("伴侣小家庭边界更清晰", "与原生家庭保持更紧密连接"),
    "parenting_style": ("规则和一致性优先", "自主和引导并重"),
    "elder_care": ("愿意承担更多家庭照护责任", "倾向社会化分担与协作"),
    "holiday_arrangement": ("节假日优先两人/小家庭安排", "节假日优先与大家庭共处"),
    "emotional_safety": ("更需要稳定回应与确定感", "更接受阶段性空间与独立"),
    "boundaries": ("边界规则明确且稳定", "边界可随关系阶段协商"),
    "closeness_style": ("偏高频黏性陪伴", "偏有连接也有独立空间"),
    "physical_affection": ("偏主动表达身体亲密", "偏循序渐进、先建立信任"),
    "vulnerability": ("愿意较早暴露脆弱面", "更晚分享脆弱、先观察安全感"),
    "weekend_style": ("偏安静陪伴或宅家", "偏户外活动与社交探索"),
    "activities": ("偏固定兴趣长期投入", "偏尝试新活动和多样体验"),
    "first_date": ("偏轻松聊天建立熟悉感", "偏共同活动快速看默契"),
    "overlap_expectation": ("希望兴趣有较高重合", "接受兴趣不同、互相尊重"),
    "hobbies": ("爱好稳定且深入", "爱好多样且变化快"),
    "learning_style": ("偏系统学习与计划推进", "偏问题驱动与边做边学"),
}

SUBTOPIC_SCENARIOS = {
    "commitment": [
        "当你和一个人连续约会 3-4 次、彼此感觉都不错时，你通常更希望怎么推进关系？",
        "如果你觉得对方整体很合适，你会倾向于哪种投入方式？",
    ],
    "trust": [
        "刚开始相处时，关于日常行程和社交互动，你更舒服的相处模式是？",
        "如果关系里出现一点不安，你更倾向于如何建立信任感？",
    ],
    "life_priorities": [
        "当工作机会和伴侣相处时间发生冲突时，你通常会优先考虑哪一侧？",
        "在你当前的人生阶段，下面哪种排序更接近你真实想法？",
    ],
    "money_values": [
        "如果未来同居或结婚，你觉得财务安排更适合哪种方式？",
        "在亲密关系里，关于花钱和存钱的节奏，你更偏向？",
    ],
    "loyalty": [
        "关于和异性朋友的互动边界，你更认可下面哪种做法？",
        "在“忠诚与自由”的平衡上，你更接近哪一侧？",
    ],
    "integrity": [
        "当你答应了伴侣一件事但临时有更方便的选择时，你通常会？",
        "对你来说，“说到做到”和“灵活调整”哪个更重要？",
    ],
    "goal_type": [
        "你开始一段关系时，通常带着怎样的目标感进入？",
        "如果要描述你当前的恋爱方向，你更接近？",
    ],
    "pace": [
        "从认识到确认关系，你更舒服的节奏通常是？",
        "当双方都有好感时，你更偏好怎样的推进速度？",
    ],
    "exclusivity": [
        "当你与某人进入稳定约会阶段时，你对“是否专一”的期待是？",
        "你更认可哪种建立排他关系的方式？",
    ],
    "future_planning": [
        "在关系前期，你会希望多早讨论未来规划（城市、婚育、职业）？",
        "面对“先聊未来还是先感受当下”，你更偏向？",
    ],
    "seriousness": [
        "你在认识新对象时，通常是怎样的心态？",
        "关于“认真筛选”和“先轻松相处”，你更接近？",
    ],
    "dating_intent": [
        "你当前使用约会产品时，更接近下面哪种目的？",
        "如果给你现在的约会状态贴标签，你更偏向？",
    ],
    "schedule": [
        "在日常作息上，你更常见的状态是？",
        "如果和伴侣协调日程，你更偏向哪种生活节奏？",
    ],
    "fitness": [
        "关于运动和健康管理，你目前的习惯更像哪一类？",
        "你对健康生活方式的投入程度更接近？",
    ],
    "travel_style": [
        "假设要一起旅行 5 天，你更偏好的旅行方式是？",
        "你和伴侣出行时，通常会采用哪种安排风格？",
    ],
    "drinking": [
        "在饮酒这件事上，你更接近哪种状态？",
        "关于社交场景中的饮酒习惯，你更偏向？",
    ],
    "spending_style": [
        "如果本月有一笔额外预算，你更可能怎么用？",
        "在消费决策上，你更靠近哪种方式？",
    ],
    "work_life_balance": [
        "当事业机会与生活陪伴冲突时，你通常会怎么取舍？",
        "你现在更倾向于哪种工作与生活平衡？",
    ],
    "social_frequency": [
        "一周结束后，你更希望通过哪种方式恢复状态？",
        "关于社交频率，你更接近以下哪种偏好？",
    ],
    "alone_time": [
        "连续相处几天后，你对独处时间的需求通常是？",
        "你在关系里对“一个人待着”的需求更接近？",
    ],
    "gatherings": [
        "朋友聚会时，你通常更享受哪种氛围？",
        "如果周末有社交活动，你更喜欢？",
    ],
    "partner_rhythm": [
        "在相处节奏上，你希望两个人的同步程度是？",
        "当双方习惯不同，你更偏好哪种处理方式？",
    ],
    "weekend_energy": [
        "周末来临时，你更想把精力放在哪里？",
        "你的周末默认模式通常更接近？",
    ],
    "crowd_preference": [
        "进入一个全新社交场景时，你更舒服的是？",
        "你在陌生人较多的场合通常会选择？",
    ],
    "conflict": [
        "发生分歧时，你通常第一反应是？",
        "吵架后你更倾向于哪种沟通节奏？",
    ],
    "texting": [
        "在消息沟通上，你通常的回复节奏更接近？",
        "你对“已读/未回”这类情况的容忍度更接近？",
    ],
    "affection_expression": [
        "表达喜欢这件事上，你更常用哪种方式？",
        "如果要让对方感受到你的在意，你更可能？",
    ],
    "date_pacing": [
        "确定关系前，你更倾向于怎样安排约会节奏？",
        "面对好感对象，你通常如何推进关系节点？",
    ],
    "feedback_style": [
        "对方做了让你不舒服的事时，你更可能怎么反馈？",
        "在沟通问题时，你更偏向哪种表达风格？",
    ],
    "emotional_expression": [
        "当你情绪低落时，你更常见的处理方式是？",
        "你在关系里表达负面情绪的方式更接近？",
    ],
    "children": [
        "关于未来是否要孩子，你当前更接近哪种看法？",
        "如果未来三到五年讨论生育计划，你更倾向？",
    ],
    "marriage_view": [
        "你如何看待婚姻在亲密关系中的位置？",
        "在“先谈质量”与“明确婚姻目标”之间，你更偏向？",
    ],
    "family_boundary": [
        "伴侣和原生家庭的边界，你更认可哪种状态？",
        "关于双方父母参与小家庭事务，你更倾向？",
    ],
    "parenting_style": [
        "如果未来有孩子，你更认同哪种育儿方式？",
        "在教育孩子时，你会更倾向哪种原则？",
    ],
    "elder_care": [
        "面对父母养老安排，你更认同哪种分工方式？",
        "如果家庭照护压力增大，你更可能选择？",
    ],
    "holiday_arrangement": [
        "节假日安排上，你更希望怎样分配时间？",
        "面对春节/长假安排，你更偏向哪种方案？",
    ],
    "emotional_safety": [
        "在关系里你更需要哪种安全感来源？",
        "你更容易在什么样的互动中感到安心？",
    ],
    "boundaries": [
        "关于关系边界（社交、隐私、时间），你更认同？",
        "你觉得边界规则应该如何形成？",
    ],
    "closeness_style": [
        "在亲密关系中，你更舒服的“黏度”是？",
        "你理想中的陪伴与空间比例更接近？",
    ],
    "physical_affection": [
        "关于身体亲密（牵手、拥抱等），你更习惯的节奏是？",
        "刚进入关系时，你对肢体亲密的推进方式更偏向？",
    ],
    "vulnerability": [
        "当你遇到挫折或脆弱时，你通常会？",
        "你在关系里分享脆弱面更常见的节奏是？",
    ],
    "weekend_style": [
        "如果两天都自由安排，你理想的周末更像？",
        "周末与伴侣相处时，你更偏向哪种状态？",
    ],
    "activities": [
        "你们一起安排活动时，你更偏好哪一类？",
        "在共同兴趣上，你更接近哪种风格？",
    ],
    "first_date": [
        "第一次线下见面，你更偏好的约会形式是？",
        "初次约会时，你更希望通过什么方式了解对方？",
    ],
    "overlap_expectation": [
        "你对“伴侣兴趣是否需要高度一致”的看法更接近？",
        "当兴趣不同时，你更期待关系如何运作？",
    ],
    "hobbies": [
        "你的兴趣爱好通常呈现出哪种状态？",
        "你在长期爱好上的投入方式更接近？",
    ],
    "learning_style": [
        "当你想掌握一项新技能时，更常见的方式是？",
        "你在学习和成长上更偏向哪种路径？",
    ],
}

QUESTION_PREFIXES = [
    "回想你最近一段真实经历，",
    "按你平时的真实做法，",
    "不考虑“标准答案”，只看你平常状态，",
    "如果这个场景发生在你身上，",
    "在你最近一两年的关系经验里，",
    "结合你过去几次亲密关系互动，",
    "按你一贯的相处习惯，",
    "把自己放回真实情境里，",
    "假设这是你本周正在面对的事，",
    "从你长期稳定的行为看，",
]

QUESTION_SUFFIXES = [
    "",
]

DEDUP_ENDINGS = [
    "",
]

UNIQUE_LEADS = [
    "通常情况下，",
    "按直觉，",
    "多数时候，",
    "先不理想化地说，",
    "更贴近现实地说，",
    "按你平时状态，",
]

LEAD_VARIANTS = [
    "按你的真实经历，",
    "按你平时的真实做法，",
    "回想你最近一段真实经历，",
    "如果遇到这种情况，",
    "把自己放回真实情境里，",
    "按你一贯的做法，",
    "更贴近现实地说，",
]

QUESTION_TIME_HINTS = [
    "想想最近三个月的自己，",
    "想想你在关系早期的状态，",
    "想想你压力大的时候，",
    "想想你状态最放松的时候，",
    "想想你和喜欢的人刚熟起来时，",
    "想想你在忙碌工作周里的反应，",
]

NEUTRAL_TEXTS = [
    "视具体情况而定",
    "会结合关系阶段调整",
    "会先观察再决定",
    "会根据双方状态灵活处理",
]

SHORTEN_REPLACEMENTS = [
    ("结合你过去几次亲密关系互动，", "按你的真实经历，"),
    ("在你最近一两年的关系经验里，", "按你的真实经历，"),
    ("不考虑“标准答案”，只看你平常状态，", "按你的真实做法，"),
    ("如果这个场景发生在你身上，", "如果是你，"),
    ("假设这是你本周正在面对的事，", "如果这事发生在你身上，"),
    ("从你长期稳定的行为看，", "按你一贯的做法，"),
    ("想想你和喜欢的人刚熟起来时，", ""),
    ("想想你在忙碌工作周里的反应，", ""),
    ("想想你在关系早期的状态，", ""),
    ("想想最近三个月的自己，", ""),
    ("想想你状态最放松的时候，", ""),
    ("下面哪一项最像你真实会说出口的话？", ""),
    ("请选一个你最不需要“演”的答案。", ""),
    ("你更容易自然地落在哪个选项上？", ""),
    ("你在大多数情况下会怎么做？", ""),
    ("你长期来看更像哪种状态？", ""),
    ("你通常会更接近哪一边？", ""),
    ("你的第一反应更可能是哪一种？", ""),
    ("你会更接近哪一项？", ""),
    ("你更接近哪一项？", ""),
    ("选最像你的一项。", ""),
    ("多数时候你会怎么做？", ""),
]

LONG_PHRASE_REPLACEMENTS = [
    ("当你和一个人连续约会 3-4 次、彼此感觉都不错时，你通常更希望怎么推进关系", "连续约会几次且彼此有好感时，你通常怎么推进关系"),
    ("刚开始相处时，关于日常行程和社交互动，你更舒服的相处模式是", "刚开始相处时，你更舒服的互动模式是"),
    ("在关系前期，你会希望多早讨论未来规划（城市、婚育、职业）", "关系前期你会多早聊未来规划（城市、婚育、职业）"),
    ("当你与某人进入稳定约会阶段时，你对“是否专一”的期待是", "进入稳定约会阶段后，你对“是否专一”的期待是"),
    ("在你当前的人生阶段，下面哪种排序更接近你真实想法", "在你当前阶段，哪种排序更接近你的真实想法"),
]


def choose_variant(items: list[str], key: str) -> str:
    if not items:
        return "以下哪种描述更接近你在关系中的真实状态？"
    idx = int(hashlib.md5(key.encode("utf-8")).hexdigest(), 16) % len(items)
    return items[idx]


def scenario_text(subtopic: str, qid: str) -> str:
    return choose_variant(SUBTOPIC_SCENARIOS.get(subtopic, []), qid)


def stylize_question(base: str, key: str) -> str:
    prefix = choose_variant(QUESTION_PREFIXES, key + "_p")
    suffix = choose_variant(QUESTION_SUFFIXES, key + "_s")
    hint = choose_variant(QUESTION_TIME_HINTS, key + "_h")
    body = base.strip().rstrip("。？！?!")
    use_hint = int(hashlib.md5((key + "_mix").encode("utf-8")).hexdigest(), 16) % 4 == 0
    lead = f"{prefix}{hint}" if use_hint else prefix
    q = f"{lead}{body}？{suffix}"
    return compact_question_text(q)


def compact_question_text(text: str) -> str:
    q = text
    for old, new in SHORTEN_REPLACEMENTS:
        q = q.replace(old, new)
    for old, new in LONG_PHRASE_REPLACEMENTS:
        q = q.replace(old, new)
    q = re.sub(r"按你的真实经历，按你的真实做法，", "按你的真实做法，", q)
    q = re.sub(r"(，){2,}", "，", q)
    q = re.sub(r"。。+", "。", q)
    q = re.sub(r"，，+", "，", q)
    q = re.sub(r"^\s*，", "", q).strip()
    if len(q) > 62:
        q = re.sub(r"按你的真实做法，", "", q, count=1)
        q = re.sub(r"按你平时的真实做法，", "", q, count=1)
        q = re.sub(r"回想你最近一段真实经历，", "", q, count=1)
        q = re.sub(r"按你一贯的相处习惯，", "", q, count=1)
    q = q.replace("你通常会更接近哪一边？", "")
    q = q.replace("如果这事发生在你身上，", "如果遇到这种情况，")
    q = q.replace("如果是你，", "如果遇到这种情况，")
    q = q.replace("请选择最接近你真实反应的一项。", "")
    q = re.sub(r"。。+", "。", q)
    q = re.sub(r"\?\?", "？", q)
    q = re.sub(r"，，+", "，", q)
    q = re.sub(r" +", "", q)
    q = q.replace("如果遇到这种情况，如果", "如果遇到这种情况，")
    q = q.replace("通常情况下，更贴近现实地说，", "更贴近现实地说，")
    q = q.replace("按直觉，如果遇到这种情况，", "如果遇到这种情况，")
    q = re.sub(r"[,，]\s*[?？]$", "？", q)
    q = re.sub(r"[,，。；]*\s*$", "", q)
    if not q.endswith("？"):
        q = q + "？"
    return q


def diversify_duplicate_questions(questions: list[dict]) -> None:
    buckets: dict[str, list[dict]] = defaultdict(list)
    for q in questions:
        zh = ((q.get("question_text") or {}).get("zh") or "").strip()
        if zh:
            buckets[zh].append(q)

    for base_text, same in buckets.items():
        if len(same) <= 1:
            continue

        stem = re.sub(r"(选最像你的一项。|你会更接近哪一项？|第一反应你会选哪项？|多数时候你会选哪项？|请按真实习惯作答。|按直觉选最贴近的一项。|请选择最接近你真实反应的一项。|你的第一反应更可能是哪一种？|你通常会更接近哪一边？|长期看你更像哪一项？|多数时候你会怎么做？|你更接近哪一项？)$", "", base_text).rstrip()
        for idx, q in enumerate(same):
            ending = DEDUP_ENDINGS[idx % len(DEDUP_ENDINGS)]
            new_text = f"{stem}{ending}"
            qt = q.get("question_text") or {}
            qt["zh"] = new_text
            q["question_text"] = qt


def ensure_global_unique_question_text(questions: list[dict]) -> None:
    seen: dict[str, int] = {}
    for q in questions:
        qt = q.get("question_text") or {}
        text = (qt.get("zh") or "").strip()
        if not text:
            continue
        idx = seen.get(text, 0)
        if idx == 0:
            seen[text] = 1
            continue

        lead = UNIQUE_LEADS[(idx - 1) % len(UNIQUE_LEADS)]
        new_text = f"{lead}{text}"
        while new_text in seen:
            idx += 1
            lead = UNIQUE_LEADS[(idx - 1) % len(UNIQUE_LEADS)]
            new_text = f"{lead}{text}"
        qt["zh"] = new_text
        q["question_text"] = qt
        seen[text] = idx + 1
        seen[new_text] = 1


def diversify_lead_opening(questions: list[dict]) -> None:
    lead_pattern = re.compile(
        r"^(按你的真实经历，|按你平时的真实做法，|回想你最近一段真实经历，|如果遇到这种情况，|把自己放回真实情境里，|按你一贯的做法，|更贴近现实地说，)"
    )
    for q in questions:
        qid = str(q.get("question_id", ""))
        qt = q.get("question_text") or {}
        text = (qt.get("zh") or "").strip()
        if not text:
            continue
        m = lead_pattern.match(text)
        if not m:
            continue
        current_lead = m.group(1)
        body = text[len(current_lead):]
        lead = choose_variant(LEAD_VARIANTS, qid + "_lead")
        qt["zh"] = f"{lead}{body}"
        q["question_text"] = qt


def update_options(options: list[dict], pole_a: str, pole_b: str) -> None:
    def clean_phrase(phrase: str) -> str:
        s = phrase.strip()
        s = s.replace("倾向于", "").replace("偏向于", "")
        s = s.replace("倾向", "").replace("偏向", "")
        s = s.replace("偏好", "喜欢")
        s = s.replace("偏", "")
        s = s.replace("更看重", "")
        s = s.replace("更强调", "")
        s = s.replace("较早", "尽早")
        s = s.replace("更偏", "")
        s = s.strip("，。 ")
        s = re.sub(r"^(于|更)", "", s).strip()
        s = s.replace("愿意愿意", "愿意")
        return s

    def degree_text(base: str, strong: bool) -> str:
        b = base.strip("，。 ")
        if b.startswith("愿意"):
            b = b[2:].strip()
        if b.startswith("希望"):
            return f"我{'非常' if strong else ''}{b}"
        if b.startswith("喜欢"):
            return f"我{'非常' if strong else '比较'}{b}"
        if b.startswith("需要"):
            return f"我{'非常' if strong else ''}{b}"
        if b.startswith("会"):
            return f"我{'通常会' if strong else '会'}{b[1:]}"
        if b.startswith("保持"):
            return f"我{'会坚持' if strong else '会'}{b}"
        if b.startswith("作息"):
            return f"我{'更' if strong else ''}{b}"
        if b.startswith("有计划") or b.startswith("随性"):
            return f"我{'明显' if strong else ''}{b}"
        if b.startswith((
            "目的", "关系", "个人", "消费", "边界", "规则", "社交", "工作", "生活", "家庭", "兴趣",
            "爱好", "重过程", "直接", "温和", "高频", "低频", "固定", "尝试", "开放", "稳定",
            "透明", "慢慢", "尽早", "主动", "循序", "晚", "以长期", "以自然"
        )):
            return f"我{'非常' if strong else '比较'}认同{b}"
        if b.startswith(("在", "把", "先", "与", "和")):
            return f"我{'非常' if strong else ''}愿意{b}"
        return f"我{'非常' if strong else ''}愿意{b}"

    def strong_text(base: str) -> str:
        return degree_text(base, True)

    def mild_text(base: str) -> str:
        return degree_text(base, False)

    a = clean_phrase(pole_a)
    b = clean_phrase(pole_b)

    n = len(options)
    if n <= 0:
        return
    if n == 1:
        templates = [(a, "Closer to the A-side preference.")]
    elif n == 2:
        templates = [
            (a, "Leaning toward the A-side preference."),
            (b, "Leaning toward the B-side preference."),
        ]
    elif n == 3:
        templates = [
            (a, "Mostly closer to the A-side preference."),
            (choose_variant(NEUTRAL_TEXTS, pole_a + pole_b), "It depends on context and relationship stage."),
            (b, "Mostly closer to the B-side preference."),
        ]
    elif n == 4:
        templates = [
            (strong_text(a), "Strongly closer to the A-side preference."),
            (mild_text(a), "Slightly closer to the A-side preference."),
            (mild_text(b), "Slightly closer to the B-side preference."),
            (strong_text(b), "Strongly closer to the B-side preference."),
        ]
    else:
        templates = []
        for i in range(n):
            if i < n / 2:
                templates.append((a, "Closer to the A-side preference."))
            else:
                templates.append((b, "Closer to the B-side preference."))

    for opt, (zh_text, en_text) in zip(options, templates):
        label = opt.get("label") or {}
        cleaned = zh_text.replace("：", "").replace("。。", "。").strip("，。 ")
        cleaned = cleaned.replace("愿意愿意", "愿意")
        label["zh"] = cleaned
        label["en"] = en_text
        opt["label"] = label


def process_file(path: Path) -> tuple[int, int]:
    data = json.loads(path.read_text(encoding="utf-8"))
    questions = data.get("questions") or []
    changed = 0
    for q in questions:
        subtopic = str(q.get("subtopic", "")).strip()
        qid = str(q.get("question_id", "")).strip()
        pole_a, pole_b = SUBTOPIC_POLES.get(
            subtopic,
            ("更看重稳定、明确与主动投入", "更看重弹性、节奏与个人空间"),
        )
        key = qid or subtopic
        zh_q = stylize_question(scenario_text(subtopic, key), key)
        q["question_text"] = {
            "zh": zh_q,
            "en": "Which option is closer to your real behavior in this situation?",
        }

        options = q.get("options") or []
        update_options(options, pole_a, pole_b)
        q["options"] = options
        changed += 1

    diversify_duplicate_questions(questions)
    ensure_global_unique_question_text(questions)
    diversify_lead_opening(questions)
    ensure_global_unique_question_text(questions)

    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return len(questions), changed


def main() -> None:
    total = 0
    updated = 0
    for f in FILES:
        count, changed = process_file(f)
        total += count
        updated += changed
        print(f"{f.name}: questions={count}, updated={changed}")
    print(f"ALL: questions={total}, updated={updated}")


if __name__ == "__main__":
    main()
