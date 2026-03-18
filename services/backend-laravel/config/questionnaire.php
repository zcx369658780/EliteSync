<?php

return [
    'session_question_count' => (int) env('QUESTIONNAIRE_SESSION_QUESTION_COUNT', 20),
    'required_answer_count' => (int) env('QUESTIONNAIRE_REQUIRED_ANSWER_COUNT', 20),
    'bank_mix_ratio' => [
        'core' => 0.50,
        'extended' => 0.30,
        'research' => 0.20,
    ],
];
