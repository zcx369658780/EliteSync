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
]

CATEGORY_ZH = {
    "values": "价值观",
    "relationship_goals": "关系目标",
    "lifestyle": "生活方式",
    "social_energy": "社交能量",
    "communication": "沟通方式",
    "family": "家庭观念",
    "intimacy": "亲密与边界",
    "interests": "兴趣偏好",
}

SUBTOPIC_ZH = {
    "commitment": "承诺方式",
    "trust": "信任建立",
    "life_priorities": "人生优先级",
    "money_values": "金钱观",
    "loyalty": "忠诚与边界",
    "integrity": "真诚一致性",
    "goal_type": "关系方向",
    "pace": "关系节奏",
    "exclusivity": "排他性",
    "future_planning": "未来规划",
    "seriousness": "认真程度",
    "dating_intent": "约会意图",
    "schedule": "作息安排",
    "fitness": "健康习惯",
    "travel_style": "旅行方式",
    "drinking": "饮酒习惯",
    "spending_style": "消费风格",
    "work_life_balance": "工作生活平衡",
    "social_frequency": "社交频率",
    "alone_time": "独处需求",
    "gatherings": "聚会偏好",
    "partner_rhythm": "伴侣节奏同步",
    "weekend_energy": "周末能量分配",
    "crowd_preference": "人群偏好",
    "conflict": "冲突处理",
    "texting": "消息沟通",
    "affection_expression": "表达爱意",
    "date_pacing": "约会推进",
    "feedback_style": "反馈方式",
    "emotional_expression": "情绪表达",
    "children": "生育观",
    "marriage_view": "婚姻观",
    "family_boundary": "家庭边界",
    "parenting_style": "育儿风格",
    "elder_care": "养老责任",
    "holiday_arrangement": "节日安排",
    "emotional_safety": "情绪安全感",
    "boundaries": "边界感",
    "closeness_style": "亲密风格",
    "physical_affection": "身体亲密",
    "vulnerability": "脆弱表达",
    "weekend_style": "周末方式",
    "activities": "活动偏好",
    "first_date": "初次约会",
    "overlap_expectation": "兴趣重合期待",
    "hobbies": "长期爱好",
    "learning_style": "学习方式",
}

STANCE = {
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

PLACEHOLDER_RE = re.compile(r"\[(CORE|EXTENDED|RESEARCH)\]|题号\d+|偏向A|偏向B|看情况")


def normalize_text(category: str, subtopic: str):
    c_zh = CATEGORY_ZH.get(category, category)
    s_zh = SUBTOPIC_ZH.get(subtopic, subtopic)
    return {
        "zh": f"在「{c_zh}·{s_zh}」这个话题里，你更接近哪种想法？",
        "en": f"In {category}/{subtopic}, which option is closer to your real preference?",
    }


def human_options(subtopic: str, n: int):
    a, b = STANCE.get(subtopic, ("更重视稳定、明确与主动投入", "更重视弹性、节奏与个人空间"))
    if n <= 1:
        return [
            ("option_1", f"更接近：{a}", f"Closer to: {a}"),
        ]
    if n == 2:
        return [
            ("option_1", f"更接近：{a}", f"Closer to: {a}"),
            ("option_2", f"更接近：{b}", f"Closer to: {b}"),
        ]
    if n == 3:
        return [
            ("option_1", f"更接近：{a}", f"Closer to: {a}"),
            ("option_2", "视具体情境而定", "It depends on the context"),
            ("option_3", f"更接近：{b}", f"Closer to: {b}"),
        ]
    return [
        ("option_1", f"明显更接近：{a}", f"Strongly closer to: {a}"),
        ("option_2", f"略偏向：{a}", f"Slightly closer to: {a}"),
        ("option_3", f"略偏向：{b}", f"Slightly closer to: {b}"),
        ("option_4", f"明显更接近：{b}", f"Strongly closer to: {b}"),
    ]


def should_rewrite_question(q: dict):
    zh = ((q.get("question_text") or {}).get("zh") or "")
    if PLACEHOLDER_RE.search(zh):
        return True
    for opt in q.get("options", []):
        opt_zh = (((opt.get("label") or {}).get("zh")) or "")
        if PLACEHOLDER_RE.search(opt_zh):
            return True
    return False


def transform_question(q: dict):
    category = str(q.get("category", "values"))
    subtopic = str(q.get("subtopic", "general"))

    q["question_text"] = normalize_text(category, subtopic)

    options = q.get("options") or []
    templates = human_options(subtopic, len(options))
    for idx, opt in enumerate(options):
        t = templates[min(idx, len(templates) - 1)]
        label = opt.get("label") or {}
        label["zh"] = t[1]
        label["en"] = t[2]
        opt["label"] = label


def process_file(path: Path):
    data = json.loads(path.read_text(encoding="utf-8"))
    questions = data.get("questions") or []
    rewritten = 0
    for q in questions:
        if should_rewrite_question(q):
            transform_question(q)
            rewritten += 1
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return len(questions), rewritten


def main():
    total = 0
    rewritten = 0
    for file in FILES:
        q_total, q_rewritten = process_file(file)
        total += q_total
        rewritten += q_rewritten
        print(f"{file.name}: total={q_total}, rewritten={q_rewritten}")
    print(f"ALL: total={total}, rewritten={rewritten}")


if __name__ == "__main__":
    main()
