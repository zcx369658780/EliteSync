<?php

return [
    'weights' => [
        'bazi' => (float) env('MATCH_ASTRO_WEIGHT_BAZI', 0.45),
        'zodiac' => (float) env('MATCH_ASTRO_WEIGHT_ZODIAC', 0.25),
        'constellation' => (float) env('MATCH_ASTRO_WEIGHT_CONSTELLATION', 0.08),
        'natal_chart' => (float) env('MATCH_ASTRO_WEIGHT_NATAL_CHART', 0.07),
        'pair_chart' => (float) env('MATCH_ASTRO_WEIGHT_PAIR_CHART', 0.15),
    ],

    'verdict_thresholds' => [
        'high' => 80,
        'medium' => 60,
    ],

    'zodiac' => [
        // Negative priority first.
        'chong' => [
            ['鼠', '马'], ['牛', '羊'], ['虎', '猴'], ['兔', '鸡'], ['龙', '狗'], ['蛇', '猪'],
        ],
        'xing' => [
            ['鼠', '兔'], ['虎', '蛇'], ['蛇', '猴'], ['牛', '狗'], ['羊', '牛'],
        ],
        'hai' => [
            ['鼠', '羊'], ['牛', '马'], ['虎', '蛇'], ['兔', '龙'], ['猴', '猪'], ['鸡', '狗'],
        ],
        'liuhe' => [
            ['鼠', '牛'], ['虎', '猪'], ['兔', '狗'], ['龙', '鸡'], ['蛇', '猴'], ['马', '羊'],
        ],
        'sanhe' => [
            ['猴', '鼠'], ['鼠', '龙'], ['猴', '龙'],
            ['蛇', '鸡'], ['鸡', '牛'], ['蛇', '牛'],
            ['虎', '马'], ['马', '狗'], ['虎', '狗'],
            ['猪', '兔'], ['兔', '羊'], ['猪', '羊'],
        ],
        'scores' => [
            'liuhe' => 100,
            'sanhe' => 85,
            'chong' => 20,
            'xing' => 30,
            'hai' => 35,
            'same' => 60,
            'normal' => 55,
        ],
        'templates' => [
            'match' => [
                'liuhe' => '属相六合，协同性较强',
                'sanhe' => '属相三合，价值取向更易对齐',
                'same' => '同属相，生活节律较接近',
                'normal' => '属相关系一般，仍可通过沟通建立默契',
                'chong' => '属相关系存在冲，冲突概率相对更高',
                'xing' => '属相关系存在刑，冲突概率相对更高',
                'hai' => '属相关系存在害，冲突概率相对更高',
            ],
            'detail' => [
                'liuhe' => '属相“六合”通常表示两者在传统关系结构中更容易形成配合感与稳定感，常作为协同信号。',
                'sanhe' => '属相“三合”表示在传统分组中更易形成共同节奏与协作倾向，加分通常略低于六合。',
                'same' => '同属相通常意味着行为节律相近，优点是容易同频，挑战是可能放大同类短板。',
                'chong' => '属相“冲”通常代表节奏对撞概率更高，容易在推进速度与表达方式上起摩擦。',
                'xing' => '属相“刑”通常代表相处中更易出现内耗或僵持，需要更主动的边界沟通。',
                'hai' => '属相“害”通常代表误解成本偏高，建议把共识确认放在互动前段。',
                'normal' => '当前组合不属于传统六合/三合，也不在冲刑害高风险组，建议以现实互动质量为主判断。',
            ],
            'risk' => '该关系类型并非“不能在一起”，而是提示磨合与沟通成本相对更高。',
        ],
    ],

    'constellation' => [
        'elements' => [
            '白羊座' => 'fire', '狮子座' => 'fire', '射手座' => 'fire',
            '金牛座' => 'earth', '处女座' => 'earth', '摩羯座' => 'earth',
            '双子座' => 'air', '天秤座' => 'air', '水瓶座' => 'air',
            '巨蟹座' => 'water', '天蝎座' => 'water', '双鱼座' => 'water',
        ],
        'score_same_element' => 85,
        'score_complement' => 75,
        'score_normal' => 60,
        'same_sign_bonus' => 5,
        'templates' => [
            'same' => [
                'match' => '同元素星座，沟通风格更易同频',
                'short' => '互动风格偏同频，推进更顺滑。',
                'detail' => '同元素组合通常在表达方式和节奏上更容易同步，过程层阻力相对更低。',
            ],
            'complement' => [
                'match' => '星座元素互补，互动张力较好',
                'short' => '元素互补，互动张力与推进节奏较好。',
                'detail' => '元素互补组合通常体现为一方推进、另一方承接更自然，初期互动更容易形成节奏。',
            ],
            'tension' => [
                'match' => '星座元素差异较大，需要主动沟通',
                'short' => '互动节奏差异较大，需主动对齐。',
                'detail' => '元素差异较大时，常见情况是表达逻辑与情绪节奏不同步，推进关系需要额外沟通。',
                'risk' => '该项主要反映相处过程是否顺滑，不代表长期结果层结论。',
            ],
            'degraded' => [
                'match' => '星座信息不完整，采用基础评分',
                'short' => '星座信息不完整，当前仅作基础参考。',
                'detail' => '因星座要素缺失，系统无法给出完整过程层判断，仅提供中性估计。',
            ],
        ],
    ],

    'bazi' => [
        'feature_weights' => [
            // Bazi 2.0 feature layer weights
            'structure' => 0.50,
            'relationship' => 0.30,
            'timing' => 0.20,
        ],
        'relation_scores' => [
            // relation between key branches (day branch preferred, year branch fallback)
            'liuhe' => 92,
            'sanhe' => 84,
            'same' => 72,
            'normal' => 60,
            'hai' => 42,
            'xing' => 38,
            'chong' => 32,
        ],
        'scoring' => [
            // V2: score = base + complement * 35 + balance * 25
            // complement: two-party wuxing distribution closeness (0~1)
            // balance: intra-profile wuxing balance average (0~1)
            'base' => 40,
            'complement_weight' => 35,
            'balance_weight' => 25,
        ],
        'templates' => [
            'full' => [
                'match' => '八字五行互补度较好，节奏更容易协调',
                'mismatch' => '八字五行分布偏差较大，可能需要更长磨合',
                'short' => '五行结构偏互补，长期磨合潜力较好。',
                'detail' => '从五行分布看，你们更偏向“互补调节”而非同侧堆叠，长期生活节律更容易形成稳定配合。',
                'risk' => '五行分布差异偏大，婚后在作息、决策与压力处理上可能出现节律不一致。',
            ],
            'similarity' => [
                'match' => '八字信息完整，基础结构相容度中等偏上',
                'mismatch' => '八字组合冲突项偏多，建议谨慎观察',
                'short' => '八字结构相容度中等偏上。',
                'detail' => '当前按八字文本结构相似度估算，倾向于“可磨合但需观察现实互动”的组合。',
                'risk' => '八字结构冲突项偏多，长期磨合成本可能偏高。',
            ],
            'degraded' => [
                'match' => '八字信息不完整，已使用保守估计',
                'mismatch' => '缺少完整八字或五行明细，结论置信度较低',
                'short' => '八字数据不完整，当前仅作保守参考。',
                'detail' => '缺少完整八字或五行明细，系统只能按简化规则估算，不建议把该项作为强结论。',
                'risk' => '建议补全出生时刻与地点，提高长期结果判断的稳定性。',
            ],
        ],
    ],

    'mbti' => [
        'weights' => [
            'base' => 45,
            'dimension_factor' => 0.55,
            'stack_factor' => 0.35,
            'lifestyle_factor' => 0.10,
            'dimension' => [
                'same_ei' => 6,
                'diff_ei' => 4,
                'same_sn' => 8,
                'diff_sn' => 3,
                'same_tf' => 8,
                'diff_tf' => 2,
                'same_jp' => 8,
                'diff_jp' => 4,
            ],
            'stack' => [
                'dominant_same' => 4,
                'dominant_aux_pair' => 6,
                'strong_strong_conflict' => -6,
            ],
            'lifestyle' => [
                'jp_conflict' => -3,
                'tf_conflict' => -3,
            ],
        ],
        'templates' => [
            'missing' => [
                'highlight' => 'MBTI 数据不完整，采用中性估计',
                'risk' => '建议补全 MBTI 结果以提高沟通适配判断可靠性',
                'short' => 'MBTI 数据不完整，当前仅作中性参考。',
                'detail' => '当前缺少完整 MBTI 结果，系统只能按简化规则估算沟通与决策节奏，不建议将该项作为强结论。',
                'risk_detail' => '建议先完成 MBTI 测试，再结合人格画像与玄学模块综合判断。',
            ],
        ],
    ],

    'pair_chart' => [
        'weights' => [
            'sun_moon_harmony' => 0.35,
            'asc_interaction' => 0.20,
            'emotion_rhythm' => 0.25,
            'long_term_stability' => 0.20,
        ],
        'templates' => [
            'high' => [
                'match' => '男女合盘协同性较高，关系推进路径更清晰',
                'short' => '情感节奏与互动推进较协调，关系升温路径清晰。',
                'detail' => '太阳-月亮互容与上升互动较顺，通常意味着过程层阻力更低、关系推进更自然。',
            ],
            'medium' => [
                'match' => '男女合盘存在互补空间，可通过沟通对齐节奏',
                'short' => '存在互补空间，建议通过沟通对齐节奏。',
                'detail' => '关键项有互补也有差异，建议在沟通节奏和边界规则上做前置约定。',
            ],
            'low' => [
                'match' => '男女合盘节奏差异较大，建议先建立边界与沟通规则',
                'short' => '互动节奏差异较明显，建议先建立边界与沟通规则。',
                'detail' => '过程层温差较明显，若缺少反馈确认机制，误解成本会偏高。',
                'risk' => '情绪回应速度与表达方式存在时差，易出现“误解并非恶意”。',
            ],
            'degraded' => [
                'detail' => '当前基于有限出生信息进行合盘估算，建议补全出生时间与地点后再复核。',
                'risk' => '当前为简化估算（出生信息不完整），准确度受限。',
            ],
        ],
    ],
];
