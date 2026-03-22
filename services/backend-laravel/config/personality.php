<?php

return [
    'dimensions' => [
        'attachment_security' => '依恋安全感',
        'emotional_regulation' => '情绪调节',
        'communication_clarity' => '沟通清晰度',
        'conflict_repair' => '冲突修复倾向',
        'reciprocity_investment' => '互惠投入',
        'commitment_readiness' => '承诺准备度',
        'autonomy_boundary' => '自主边界感',
        'empathy_responsiveness' => '共情回应性',
        'planning_reliability' => '计划与可靠性',
        'openness_exploration' => '开放探索性',
        'rejection_resilience' => '拒绝韧性',
        'intimacy_disclosure' => '亲密披露深度',
        'social_initiative' => '社交主动性',
    ],

    'matching_weights' => [
        'attachment_security' => 1.2,
        'emotional_regulation' => 1.2,
        'communication_clarity' => 1.1,
        'conflict_repair' => 1.15,
        'reciprocity_investment' => 1.1,
        'commitment_readiness' => 1.15,
        'autonomy_boundary' => 1.0,
        'empathy_responsiveness' => 1.1,
        'planning_reliability' => 1.05,
        'openness_exploration' => 1.0,
        'rejection_resilience' => 1.1,
        'intimacy_disclosure' => 1.05,
        'social_initiative' => 1.0,
    ],

    'complementary_dimensions' => [
        'social_initiative',
        'openness_exploration',
    ],

    // V2 prefers option-level dimension_weights from question bank.
    // Keep this for backward compatibility with legacy question keys.
    'question_scoring' => [],
];
