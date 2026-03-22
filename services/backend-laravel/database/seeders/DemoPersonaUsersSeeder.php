<?php

namespace Database\Seeders;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Database\Seeder;

class DemoPersonaUsersSeeder extends Seeder
{
    public function run(): void
    {
        $questions = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->orderBy('sort_order')
            ->limit(10)
            ->get(['id', 'options']);

        if ($questions->count() < 10) {
            return;
        }

        $personas = [
            ['name' => '稳健理性型', 'answer_indexes' => [0, 0, 0, 1, 0, 1, 0, 0, 1, 0]],
            ['name' => '外向行动型', 'answer_indexes' => [1, 1, 2, 2, 1, 2, 1, 1, 2, 1]],
            ['name' => '温和保守型', 'answer_indexes' => [2, 2, 1, 0, 2, 0, 2, 2, 0, 2]],
            ['name' => '谨慎规划型', 'answer_indexes' => [0, 3, 0, 0, 0, 1, 2, 0, 0, 1]],
            ['name' => '共情照顾型', 'answer_indexes' => [1, 0, 1, 1, 0, 1, 0, 1, 1, 0]],
            ['name' => '现实平衡型', 'answer_indexes' => [2, 1, 2, 1, 2, 2, 1, 2, 1, 2]],
            ['name' => '直接表达型', 'answer_indexes' => [0, 0, 1, 0, 1, 0, 0, 1, 0, 0]],
            ['name' => '稳定慢热型', 'answer_indexes' => [3, 2, 2, 2, 3, 2, 2, 3, 2, 3]],
            ['name' => '探索冒险型', 'answer_indexes' => [2, 3, 3, 3, 2, 3, 3, 2, 3, 2]],
            ['name' => '边界清晰型', 'answer_indexes' => [0, 1, 0, 1, 0, 1, 0, 1, 0, 1]],
        ];

        foreach ($personas as $idx => $persona) {
            $phone = sprintf('1390000%04d', $idx + 1);
            $user = User::updateOrCreate(
                ['phone' => $phone],
                [
                    'name' => 'Demo'.$phone.'-'.$persona['name'],
                    'password' => 'secret123',
                    'verify_status' => 'approved',
                    'disabled' => false,
                ]
            );

            foreach ($questions as $qIdx => $question) {
                $optionIds = collect($question->options ?? [])->pluck('option_id')->filter()->values()->all();
                if (count($optionIds) === 0) {
                    continue;
                }
                $pickIndex = (int) ($persona['answer_indexes'][$qIdx] ?? 0);
                $selected = (string) ($optionIds[min($pickIndex, count($optionIds) - 1)] ?? $optionIds[0]);

                QuestionnaireAnswer::updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'questionnaire_question_id' => (int) $question->id,
                    ],
                    [
                        'answer_payload' => [
                            'value' => $selected,
                            'selected_answer' => [$selected],
                            'acceptable_answers' => [$selected],
                            'importance' => 2,
                            'importance_weight' => 0.66,
                            'version' => 1,
                        ],
                        'selected_answer_json' => [$selected],
                        'acceptable_answers_json' => [$selected],
                        'importance' => 2,
                        'version' => 1,
                    ]
                );
            }
        }
    }
}
