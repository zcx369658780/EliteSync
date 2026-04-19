<?php

return [
    'version' => env('QUESTIONNAIRE_VERSION', 'q_v2'),
    'bank_version' => env('QUESTIONNAIRE_BANK_VERSION', 'qb_v1'),
    'attempt_version' => env('QUESTIONNAIRE_ATTEMPT_VERSION', 'qa_v1'),
    'label' => env('QUESTIONNAIRE_LABEL', '非官方人格四维问卷'),
    'non_official_notice' => env(
        'QUESTIONNAIRE_NON_OFFICIAL_NOTICE',
        '仅用于产品内人格倾向参考，不代表官方 MBTI。'
    ),
    'estimated_minutes' => (int) env('QUESTIONNAIRE_ESTIMATED_MINUTES', 6),
    'session_question_count' => (int) env('QUESTIONNAIRE_SESSION_QUESTION_COUNT', 20),
    'required_answer_count' => (int) env('QUESTIONNAIRE_REQUIRED_ANSWER_COUNT', 20),
    'bank_mix_ratio' => [
        'core' => 0.50,
        'extended' => 0.30,
        'research' => 0.20,
    ],
    // production default: prioritize better discrimination questions
    'allowed_quality_tiers' => ['high', 'normal'],
    // low tier refinement:
    // pass: high/normal quality
    // low_keep: low quality but still usable fallback
    // low_drop: to be deprecated; only used in final emergency fallback
    'primary_quality_tags' => ['pass', 'low_keep'],
    'fallback_quality_tags' => ['pass', 'low_keep', 'low_drop'],
];
