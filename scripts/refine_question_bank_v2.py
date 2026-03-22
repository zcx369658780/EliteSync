#!/usr/bin/env python3
import hashlib
import json
import re
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
    "trust": ("高透明度和及时沟通", "慢慢建立信任并保留空间"),
    "life_priorities": ("关系与共同生活优先", "个人发展与独立节奏优先"),
    "money_values": ("消费与储蓄尽量协同", "保留各自财务习惯与自主度"),
    "loyalty": ("边界清晰、排他性更强", "边界可协商、社交更开放"),
    "integrity": ("言行一致和承诺兑现", "当下感受和灵活调整"),
    "goal_type": ("以长期稳定关系为目标", "以自然相处和阶段体验为目标"),
    "pace": ("推进节奏更明确", "慢节奏逐步深入"),
    "exclusivity": ("较早建立专一关系", "先开放了解再决定是否专一"),
    "future_planning": ("尽早讨论未来计划", "先享受当下再谈未来"),
    "seriousness": ("从一开始就认真筛选", "先轻松相处，合适再升级"),
    "dating_intent": ("目的明确、重匹配效率", "重过程体验并保留探索空间"),
    "schedule": ("作息规律、计划性更强", "作息灵活、顺应状态变化"),
    "fitness": ("固定投入运动和健康管理", "保持适度，不强求规律"),
    "travel_style": ("有计划、有节奏地旅行", "随性并临场决定旅行安排"),
    "drinking": ("克制或少饮", "社交场景下适度饮酒"),
    "spending_style": ("理性预算与长期规划", "体验消费与当下满足"),
    "work_life_balance": ("生活优先并保留留白", "事业投入和成长机会优先"),
    "social_frequency": ("高频社交更有能量", "低频社交、深度连接更舒适"),
    "alone_time": ("需要较多独处恢复", "更习惯在陪伴中恢复"),
    "gatherings": ("更喜欢小范围深聊", "更喜欢多人活动与热闹氛围"),
    "partner_rhythm": ("希望两人节奏高度同步", "允许节奏差异并保留弹性"),
    "weekend_energy": ("周末偏休整与充电", "周末偏探索与外出"),
    "crowd_preference": ("偏安静熟悉环境", "偏新鲜人群与公开场景"),
    "conflict": ("及时直面问题", "先冷静再沟通"),
    "texting": ("高频即时回复", "低频但完整回复"),
    "affection_expression": ("直接表达爱意", "用行动与细节表达"),
    "date_pacing": ("更快推进关系节点", "慢慢确认再推进"),
    "feedback_style": ("直接反馈、问题导向", "温和反馈、情绪照顾优先"),
    "emotional_expression": ("外显情绪并讨论", "内化整理后再表达"),
    "children": ("积极考虑生育计划", "谨慎或暂不考虑生育"),
    "marriage_view": ("将婚姻作为重要目标", "先看关系质量再谈婚姻"),
    "family_boundary": ("伴侣小家庭边界更清晰", "与原生家庭保持更紧密连接"),
    "parenting_style": ("规则和一致性优先", "自主和引导并重"),
    "elder_care": ("承担更多家庭照护责任", "社会化分担与协作"),
    "holiday_arrangement": ("节假日优先两人/小家庭安排", "节假日优先与大家庭共处"),
    "emotional_safety": ("稳定回应与确定感", "阶段性空间与独立"),
    "boundaries": ("边界规则明确且稳定", "边界可随关系阶段协商"),
    "closeness_style": ("高频黏性陪伴", "有连接也有独立空间"),
    "physical_affection": ("主动表达身体亲密", "循序渐进并先建立信任"),
    "vulnerability": ("较早暴露脆弱面", "更晚分享脆弱并先观察安全感"),
    "weekend_style": ("安静陪伴或宅家", "户外活动与社交探索"),
    "activities": ("固定兴趣长期投入", "尝试新活动和多样体验"),
    "first_date": ("轻松聊天建立熟悉感", "共同活动快速看默契"),
    "overlap_expectation": ("希望兴趣有较高重合", "接受兴趣不同并互相尊重"),
    "hobbies": ("爱好稳定且深入", "爱好多样且变化快"),
    "learning_style": ("系统学习与计划推进", "问题驱动与边做边学"),
}

SCENARIOS = {
    "commitment": ["如果你觉得对方整体很合适，你会怎么推进关系？", "当你们连续约会几次且彼此有好感时，你会怎么推进关系？"],
    "trust": ["如果关系里出现一点不安，你会怎么建立信任感？", "刚开始相处时，你更舒服的互动方式是什么？"],
    "life_priorities": ["当工作机会和相处时间冲突时，你通常怎么取舍？", "在你当前阶段，哪种优先级更贴近你？"],
    "money_values": ["如果未来同居或结婚，你更认可哪种财务安排？", "在亲密关系里，花钱和存钱你更接近哪种节奏？"],
    "loyalty": ["在“忠诚与自由”的平衡上，你更接近哪一侧？", "关于异性社交边界，你更认同哪种做法？"],
    "integrity": ["当承诺与便利冲突时，你通常怎么做？", "在“说到做到”和“灵活调整”之间，你更看重哪一边？"],
    "goal_type": ["你开始一段关系时，通常抱着什么目标？", "如果描述你当前的恋爱方向，你更接近哪种？"],
    "pace": ["从认识到确认关系，你更舒服的节奏是什么？", "双方都有好感时，你更偏好怎样推进？"],
    "exclusivity": ["进入稳定约会阶段后，你对“是否专一”的期待是什么？", "你更认同哪种建立排他关系的方式？"],
    "future_planning": ["关系前期，你会多早讨论未来规划（城市/婚育/职业）？", "面对“先聊未来还是先感受当下”，你更接近哪一边？"],
    "seriousness": ["认识新对象时，你通常是什么心态？", "在“认真筛选”和“先轻松相处”之间，你更接近哪一侧？"],
    "dating_intent": ["你当前使用约会产品的目的更接近哪一种？", "如果给你的约会状态贴标签，你会选哪一类？"],
    "schedule": ["和伴侣协调日程时，你更偏向哪种生活节奏？", "在日常作息上，你更常见的状态是什么？"],
    "fitness": ["关于运动和健康管理，你目前更接近哪种习惯？", "你对健康生活方式的投入更接近哪一种？"],
    "travel_style": ["假设一起旅行 5 天，你更偏好哪种方式？", "你和伴侣出行时，通常怎么安排节奏？"],
    "drinking": ["在饮酒这件事上，你更接近哪种状态？", "关于社交场景中的饮酒习惯，你更贴近哪种？"],
    "spending_style": ["如果本月有一笔额外预算，你更可能怎么用？", "在消费决策上，你更靠近哪种方式？"],
    "work_life_balance": ["当事业机会和生活陪伴冲突时，你通常怎么取舍？", "你现在更倾向于哪种工作与生活平衡？"],
    "social_frequency": ["一周结束后，你更希望通过什么方式恢复状态？", "关于社交频率，你更接近哪种偏好？"],
    "alone_time": ["连续相处几天后，你对独处时间的需求是什么？", "在关系里，你对“一个人待着”的需求更接近哪种？"],
    "gatherings": ["朋友聚会时，你通常更享受哪种氛围？", "如果周末有社交活动，你更喜欢哪种类型？"],
    "partner_rhythm": ["在相处节奏上，你希望同步到什么程度？", "当双方习惯不同，你更偏好怎么处理？"],
    "weekend_energy": ["周末来临时，你更想把精力放在哪里？", "你的周末默认状态更接近哪种？"],
    "crowd_preference": ["进入新社交场景时，你更舒服的状态是什么？", "在陌生人较多的场合，你通常会怎么选？"],
    "conflict": ["发生分歧时，你通常第一反应是什么？", "吵架后，你更倾向于哪种沟通节奏？"],
    "texting": ["在消息沟通上，你通常的回复节奏是什么？", "你对“已读/未回”这类情况的容忍度更接近哪种？"],
    "affection_expression": ["表达喜欢时，你更常用哪种方式？", "要让对方感受到你的在意，你更可能怎么做？"],
    "date_pacing": ["确定关系前，你更倾向于怎样安排约会节奏？", "面对好感对象，你通常如何推进关系节点？"],
    "feedback_style": ["对方做了让你不舒服的事时，你更可能怎么反馈？", "在沟通问题时，你更偏向哪种表达风格？"],
    "emotional_expression": ["当你情绪低落时，你更常见的处理方式是什么？", "在关系里表达负面情绪时，你更接近哪种方式？"],
    "children": ["关于未来是否要孩子，你当前更接近哪种看法？", "如果未来三到五年讨论生育计划，你更倾向哪一边？"],
    "marriage_view": ["你如何看待婚姻在亲密关系中的位置？", "在“先看关系质量”和“明确婚姻目标”之间，你更偏向哪一边？"],
    "family_boundary": ["伴侣和原生家庭的边界，你更认同哪种状态？", "关于双方父母参与小家庭事务，你更倾向哪种边界？"],
    "parenting_style": ["如果未来有孩子，你更认同哪种育儿方式？", "在教育孩子时，你更偏向哪种原则？"],
    "elder_care": ["面对父母养老安排，你更认同哪种分工？", "如果家庭照护压力增大，你更可能怎么安排？"],
    "holiday_arrangement": ["节假日安排上，你更希望怎样分配时间？", "面对春节/长假安排，你更偏向哪种方案？"],
    "emotional_safety": ["在关系里，你更需要哪种安全感来源？", "你更容易在什么样的互动里感到安心？"],
    "boundaries": ["关于关系边界（社交/隐私/时间），你更认同哪种？", "你觉得边界规则更适合怎么形成？"],
    "closeness_style": ["在亲密关系中，你更舒服的“黏度”是什么？", "你理想中的“陪伴-空间”比例更接近哪一边？"],
    "physical_affection": ["关于身体亲密（牵手/拥抱等），你更习惯哪种节奏？", "刚进入关系时，你对肢体亲密的推进方式更偏向哪种？"],
    "vulnerability": ["当你遇到挫折或脆弱时，你通常会怎么做？", "在关系里分享脆弱面时，你更常见的节奏是什么？"],
    "weekend_style": ["如果两天都自由安排，你理想的周末更像哪种？", "周末与伴侣相处时，你更偏向哪种状态？"],
    "activities": ["你们一起安排活动时，你更偏好哪一类？", "在共同兴趣上，你更接近哪种风格？"],
    "first_date": ["第一次线下见面，你更偏好的约会形式是什么？", "初次约会时，你更希望通过哪种方式了解对方？"],
    "overlap_expectation": ["你对“伴侣兴趣是否需要高度一致”更接近哪种看法？", "当兴趣不同，你更期待关系如何运作？"],
    "hobbies": ["你的兴趣爱好通常是什么状态？", "你在长期爱好上的投入方式更接近哪种？"],
    "learning_style": ["当你想掌握一项新技能时，你更常用哪种方式？", "你在学习和成长上更偏向哪种路径？"],
}

INTROS = [
    "",
    "回想最近一段真实经历，",
    "按你平时的做法，",
    "如果遇到这种情况，",
    "更贴近现实地说，",
]

NEUTRAL_3 = [
    "会根据具体情况调整",
    "会结合关系阶段来决定",
    "会先观察再做决定",
    "会看双方状态灵活处理",
]


def pick(items: list[str], key: str) -> str:
    idx = int(hashlib.md5(key.encode("utf-8")).hexdigest(), 16) % len(items)
    return items[idx]


def normalize_text(s: str) -> str:
    t = s.strip()
    t = t.replace("倾向于", "").replace("偏向于", "")
    t = t.replace("倾向", "").replace("偏向", "")
    t = t.replace("偏好", "喜欢")
    t = t.replace("更看重", "")
    t = t.replace("更强调", "")
    t = t.replace("较早", "尽早")
    t = t.replace("愿意愿意", "愿意")
    t = re.sub(r"^(于|更)", "", t).strip("，。 ")
    return t


def question_zh(subtopic: str, qid: str) -> str:
    scenarios = SCENARIOS.get(subtopic, ["下面哪种状态更接近你的真实情况？"])
    body = pick(scenarios, qid + "_s")
    intro = pick(INTROS, qid + "_i")
    text = f"{intro}{body}".strip()
    text = text.replace("，，", "，")
    text = re.sub(r"^(，)+", "", text)
    text = re.sub(r"[。？！?]+$", "", text)
    return text + "？"


def degree_4(a: str, b: str, qid: str) -> list[str]:
    style = int(hashlib.md5((qid + "_d4").encode("utf-8")).hexdigest(), 16) % 3
    if style == 0:
        return [
            f"我非常认同{a}",
            f"我比较认同{a}",
            f"我比较认同{b}",
            f"我非常认同{b}",
        ]
    if style == 1:
        return [
            f"对我来说，{a}最贴近真实状态",
            f"大多数时候，我会选择{a}",
            f"大多数时候，我会选择{b}",
            f"对我来说，{b}最贴近真实状态",
        ]
    return [
        f"我会优先{a}",
        f"我比较会考虑{a}",
        f"我比较会考虑{b}",
        f"我会优先{b}",
    ]


def labels_for(n: int, a: str, b: str, qid: str) -> list[str]:
    if n <= 1:
        return [a]
    if n == 2:
        return [a, b]
    if n == 3:
        return [a, pick(NEUTRAL_3, qid + "_n3"), b]
    return degree_4(a, b, qid)


def process(path: Path) -> tuple[int, int]:
    data = json.loads(path.read_text(encoding="utf-8"))
    qs = data.get("questions") or []
    changed = 0
    for q in qs:
        qid = str(q.get("question_id", ""))
        sub = str(q.get("subtopic", ""))
        a, b = SUBTOPIC_POLES.get(sub, ("保持稳定与明确", "保留弹性与空间"))
        a = normalize_text(a)
        b = normalize_text(b)

        q["question_text"] = {
            "zh": question_zh(sub, qid),
            "en": "Which option is closer to your real behavior?",
        }

        opts = q.get("options") or []
        labels = labels_for(len(opts), a, b, qid)
        for i, opt in enumerate(opts):
            label = opt.get("label") or {}
            zh = labels[min(i, len(labels) - 1)]
            zh = zh.replace("愿意愿意", "愿意").replace("我倾向慢慢", "我倾向于慢慢")
            label["zh"] = zh
            label["en"] = label.get("en", "")
            opt["label"] = label
        q["options"] = opts
        changed += 1

    # ensure question text uniqueness in one bank to avoid copy feeling
    seen: dict[str, int] = {}
    for q in qs:
        zh = (q.get("question_text") or {}).get("zh", "")
        c = seen.get(zh, 0)
        if c > 0:
            extra = ["（按真实习惯）", "（按常见状态）", "（按你平常做法）"][min(c - 1, 2)]
            q["question_text"]["zh"] = zh[:-1] + extra + "？"
        seen[zh] = c + 1

    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return len(qs), changed


def main() -> None:
    total = 0
    changed = 0
    for f in FILES:
        n, c = process(f)
        total += n
        changed += c
        print(f"{f.name}: questions={n}, updated={c}")
    print(f"ALL: questions={total}, updated={changed}")


if __name__ == "__main__":
    main()
