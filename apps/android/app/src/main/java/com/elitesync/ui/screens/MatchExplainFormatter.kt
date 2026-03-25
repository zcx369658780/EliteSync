package com.elitesync.ui.screens

private val EvidenceTagZhMap: Map<String, String> = mapOf(
    "wu_xing_complement" to "五行互补度",
    "long_term_harmony_oriented" to "长期稳定取向",
    "bazi_similarity_estimation" to "八字相似度估算",
    "bazi_degraded_estimation" to "八字降级估算",
    "missing_bazi" to "缺少八字数据",
    "confidence_medium" to "中等置信度",
    "zodiac_liuhe" to "属相六合",
    "zodiac_sanhe" to "属相三合",
    "zodiac_same" to "同属相",
    "zodiac_chong" to "属相相冲",
    "zodiac_hai" to "属相相害",
    "zodiac_xing" to "属相相刑",
    "zodiac_normal" to "属相关系一般",
    "same_element" to "同元素星座",
    "element_complement" to "元素互补",
    "element_tension" to "元素张力",
    "process_layer_signal" to "过程层信号",
    "missing_constellation" to "缺少星座数据",
    "natal_chart_partial_data" to "星盘数据部分缺失",
    "moon_sync_high" to "月亮节奏同步高",
    "moon_sync_low" to "月亮节奏同步低",
    "asc_style_match" to "上升风格匹配",
    "asc_style_gap" to "上升风格差异",
    "mbti_complementary_axes" to "MBTI 维度互补",
    "mbti_conflict_axes" to "MBTI 维度冲突",
    "mbti_missing_data" to "MBTI 数据不完整",
    "personality_alignment_high" to "性格维度高度一致",
    "personality_alignment_medium" to "性格维度中度一致",
    "personality_alignment_low" to "性格维度差异较大",
    "pair_chart_v1" to "男女合盘模型",
    "sun_moon_harmony" to "太阳月亮互容",
    "emotion_rhythm" to "情绪节奏同步",
    "pair_chart_harmony" to "合盘协同信号",
    "pair_chart_tension" to "合盘张力信号",
    "pair_chart_degraded" to "合盘降级估算",
    "same_city_boost" to "同城加权",
    "age_gap_adjustment" to "年龄差修正",
    "mbti_letter_match" to "MBTI 字母匹配修正",
    "communication_mismatch" to "沟通风格惩罚"
)

fun humanizeEvidenceTag(tag: String): String {
    val trimmed = tag.trim()
    if (trimmed.isBlank()) return trimmed
    return EvidenceTagZhMap[trimmed]
        ?: trimmed.replace('_', ' ')
}

fun humanizeEvidenceTags(tags: List<String>): String {
    return tags
        .asSequence()
        .map { humanizeEvidenceTag(it) }
        .filter { it.isNotBlank() }
        .distinct()
        .joinToString(" | ")
}

private val PenaltyKeyZhMap: Map<String, String> = mapOf(
    "same_city_boost" to "同城加成",
    "age_gap_adjustment" to "年龄差修正",
    "mbti_letter_match" to "MBTI 字母匹配修正",
    "communication_mismatch" to "沟通风格惩罚",
    "interest_overlap_low" to "兴趣重叠度惩罚",
    "lifestyle_mismatch" to "生活方式惩罚",
    "relationship_goal_partial_mismatch" to "婚恋目标差异惩罚"
)

fun humanizePenaltyFactor(key: String): String {
    val trimmed = key.trim()
    if (trimmed.isBlank()) return trimmed
    return PenaltyKeyZhMap[trimmed] ?: trimmed.replace('_', ' ')
}

fun humanizePenaltyFactorLine(key: String, value: Double): String {
    val name = humanizePenaltyFactor(key)
    val ratio = String.format("%.2f", value)
    val trend = when {
        value > 1.0 -> "（加成）"
        value < 1.0 -> "（惩罚）"
        else -> "（中性）"
    }
    return "$name: $ratio $trend"
}
