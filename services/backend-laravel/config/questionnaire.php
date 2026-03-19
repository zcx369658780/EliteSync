<?php

return [
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
