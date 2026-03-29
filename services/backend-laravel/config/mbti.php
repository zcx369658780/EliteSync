<?php

return [
    'default_version' => 'lite3_v1',
    'quiz_sets' => [
        'lite3_v1' => [
            'label' => 'MBTI Lite 3',
            'items' => [
                [
                    'question_id' => 1,
                    'content' => '周五晚上你更想',
                    'option_a_text' => '约人出去走走，想到哪玩到哪',
                    'option_b_text' => '按自己的节奏待着，做点安静的事',
                    'mapping' => [
                        'A' => ['E' => 2, 'P' => 1],
                        'B' => ['I' => 2, 'J' => 1],
                    ],
                ],
                [
                    'question_id' => 2,
                    'content' => '面对一个新计划（旅行/学习），你通常先',
                    'option_a_text' => '看灵感和可能性，边看边决定',
                    'option_b_text' => '看已知信息和步骤，先搭好框架',
                    'mapping' => [
                        'A' => ['N' => 2, 'P' => 1],
                        'B' => ['S' => 2, 'J' => 1],
                    ],
                ],
                [
                    'question_id' => 3,
                    'content' => '朋友因合作分歧来找你，你第一反应',
                    'option_a_text' => '先理解感受和关系，再聊方案',
                    'option_b_text' => '先厘清事实和利弊，再给建议',
                    'mapping' => [
                        'A' => ['F' => 2, 'I' => 1],
                        'B' => ['T' => 2, 'E' => 1],
                    ],
                ],
            ],
        ],
        'lite5_v1' => [
            'label' => 'MBTI Lite 5',
            'items' => [
                [
                    'question_id' => 1,
                    'content' => '周五晚上你更想',
                    'option_a_text' => '约人出去走走，想到哪玩到哪',
                    'option_b_text' => '按自己的节奏待着，做点安静的事',
                    'mapping' => [
                        'A' => ['E' => 2, 'P' => 1],
                        'B' => ['I' => 2, 'J' => 1],
                    ],
                ],
                [
                    'question_id' => 2,
                    'content' => '面对一个新计划（旅行/学习），你通常先',
                    'option_a_text' => '看灵感和可能性，边看边决定',
                    'option_b_text' => '看已知信息和步骤，先搭好框架',
                    'mapping' => [
                        'A' => ['N' => 2, 'P' => 1],
                        'B' => ['S' => 2, 'J' => 1],
                    ],
                ],
                [
                    'question_id' => 3,
                    'content' => '朋友因合作分歧来找你，你第一反应',
                    'option_a_text' => '先理解感受和关系，再聊方案',
                    'option_b_text' => '先厘清事实和利弊，再给建议',
                    'mapping' => [
                        'A' => ['F' => 2, 'I' => 1],
                        'B' => ['T' => 2, 'E' => 1],
                    ],
                ],
                [
                    'question_id' => 4,
                    'content' => '做决定时你更依赖',
                    'option_a_text' => '客观标准和可验证事实',
                    'option_b_text' => '关系感受和价值取向',
                    'mapping' => [
                        'A' => ['T' => 2, 'J' => 1],
                        'B' => ['F' => 2, 'P' => 1],
                    ],
                ],
                [
                    'question_id' => 5,
                    'content' => '旅行前你更倾向',
                    'option_a_text' => '提前订好行程和关键节点',
                    'option_b_text' => '保留弹性，现场再决定',
                    'mapping' => [
                        'A' => ['J' => 2, 'S' => 1],
                        'B' => ['P' => 2, 'N' => 1],
                    ],
                ],
            ],
        ],
    ],
];

