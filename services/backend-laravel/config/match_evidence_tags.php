<?php

return [
    // Bazi
    'bazi_feature_extractor_v1' => [
        'label' => '八字特征提取',
        'description' => '八字2.0特征层输出（结构/关系/时间）',
        'terms' => ['八字', '五行'],
    ],
    'wu_xing_complement' => [
        'label' => '五行互补',
        'description' => '双方五行分布互补度较高',
        'reference' => '《五行大义》互补观念（工程化简化映射）',
        'terms' => ['八字', '五行'],
    ],
    'wu_xing_same_dominant' => [
        'label' => '同主元素',
        'description' => '双方主导五行一致',
        'terms' => ['八字', '五行'],
    ],
    'wu_xing_dominant_complement' => [
        'label' => '主元素互补',
        'description' => '双方主导五行具有互补关系',
        'terms' => ['八字', '五行'],
    ],
    'bazi_branch_liuhe' => [
        'label' => '地支六合',
        'description' => '关键地支关系为六合',
        'reference' => '《三命通会》地支关系条目（工程化映射）',
        'terms' => ['八字', '属相六合'],
    ],
    'bazi_branch_sanhe' => [
        'label' => '地支三合',
        'description' => '关键地支关系为三合',
        'reference' => '《三命通会》地支关系条目（工程化映射）',
        'terms' => ['八字', '属相三合'],
    ],
    'bazi_branch_chong' => [
        'label' => '地支相冲',
        'description' => '关键地支关系为相冲',
        'reference' => '《三命通会》地支关系条目（工程化映射）',
        'terms' => ['八字', '相冲/相刑/相害'],
    ],
    'bazi_branch_xing' => [
        'label' => '地支相刑',
        'description' => '关键地支关系为相刑',
        'reference' => '《三命通会》地支关系条目（工程化映射）',
        'terms' => ['八字', '相冲/相刑/相害'],
    ],
    'bazi_branch_hai' => [
        'label' => '地支相害',
        'description' => '关键地支关系为相害',
        'reference' => '《三命通会》地支关系条目（工程化映射）',
        'terms' => ['八字', '相冲/相刑/相害'],
    ],
    'bazi_timing_sync_high' => [
        'label' => '岁运节律同步',
        'description' => '流年/运势节律重叠度较高',
        'terms' => ['八字'],
    ],
    'bazi_timing_sync_low' => [
        'label' => '岁运节律偏差',
        'description' => '流年/运势节律重叠度较低',
        'terms' => ['八字'],
    ],
    'bazi_timing_partial' => [
        'label' => '岁运信息不足',
        'description' => '缺少完整流年/大运信息，已降级估算',
        'terms' => ['八字'],
    ],

    // Zodiac
    'zodiac_liuhe' => [
        'label' => '属相六合',
        'description' => '属相关系为六合',
        'reference' => '十二生肖六合配对传统规则（工程化映射）',
        'terms' => ['属相六合'],
    ],
    'zodiac_sanhe' => [
        'label' => '属相三合',
        'description' => '属相关系为三合',
        'reference' => '十二生肖三合配对传统规则（工程化映射）',
        'terms' => ['属相三合'],
    ],
    'zodiac_chong' => [
        'label' => '属相相冲',
        'description' => '属相关系为相冲',
        'reference' => '十二生肖冲刑害传统关系（工程化映射）',
        'terms' => ['相冲/相刑/相害'],
    ],
    'zodiac_xing' => [
        'label' => '属相相刑',
        'description' => '属相关系为相刑',
        'reference' => '十二生肖冲刑害传统关系（工程化映射）',
        'terms' => ['相冲/相刑/相害'],
    ],
    'zodiac_hai' => [
        'label' => '属相相害',
        'description' => '属相关系为相害',
        'reference' => '十二生肖冲刑害传统关系（工程化映射）',
        'terms' => ['相冲/相刑/相害'],
    ],

    // Western
    'natal_chart_partial_data' => [
        'label' => '星盘信息不完整',
        'description' => '上升或月亮等关键信息缺失',
        'terms' => ['星盘'],
    ],
    'sun_moon_harmony' => [
        'label' => '日月互动和谐',
        'description' => '太阳/月亮互动倾向较顺',
        'reference' => '现代占星常见日月互动框架（工程化映射）',
        'terms' => ['合盘', '星盘'],
    ],
    'asc_style_match' => [
        'label' => '上升风格协调',
        'description' => '上升星座互动风格较易对齐',
        'reference' => '现代占星上升互动框架（工程化映射）',
        'terms' => ['合盘', '星盘'],
    ],
    'emotion_rhythm' => [
        'label' => '情绪节奏一致',
        'description' => '情绪回应和互动节奏较一致',
        'reference' => '现代占星月亮互动与情绪节奏框架（工程化映射）',
        'terms' => ['合盘'],
    ],
    'long_term_stability' => [
        'label' => '长期稳定支撑',
        'description' => '长期关系稳定项表现较好',
        'reference' => '土星/长期承诺象征框架与八字岁运协同（工程化映射）',
        'terms' => ['合盘', '八字'],
    ],
    'pair_chart_v2' => [
        'label' => '合盘2.0特征',
        'description' => '合盘按结构化特征分项计算',
        'terms' => ['合盘'],
    ],
    'pair_chart_harmony' => [
        'label' => '合盘协同',
        'description' => '合盘过程层协同较好',
        'terms' => ['合盘'],
    ],
    'pair_chart_tension' => [
        'label' => '合盘张力',
        'description' => '合盘过程层存在张力',
        'terms' => ['合盘'],
    ],
];
