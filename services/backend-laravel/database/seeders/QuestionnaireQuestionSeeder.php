<?php

namespace Database\Seeders;

use App\Models\QuestionnaireQuestion;
use Illuminate\Database\Seeder;
use RuntimeException;

class QuestionnaireQuestionSeeder extends Seeder
{
    public function run(): void
    {
        $jsonPath = realpath(base_path('..'.DIRECTORY_SEPARATOR.'..'.DIRECTORY_SEPARATOR.'dating_question_bank_v_1.json'));
        if (!$jsonPath || !is_file($jsonPath)) {
            throw new RuntimeException('question bank json not found: dating_question_bank_v_1.json');
        }

        $raw = file_get_contents($jsonPath);
        $payload = json_decode((string) $raw, true);
        if (!is_array($payload) || !isset($payload['questions']) || !is_array($payload['questions'])) {
            throw new RuntimeException('invalid question bank json format');
        }

        $seenKeys = [];
        $sortOrder = 1;

        foreach ($payload['questions'] as $q) {
            $questionKey = (string) ($q['question_id'] ?? '');
            if ($questionKey === '') {
                continue;
            }
            $seenKeys[] = $questionKey;

            $options = array_map(function (array $opt) {
                return [
                    'option_id' => (string) ($opt['option_id'] ?? ''),
                    'label' => [
                        'zh' => (string) data_get($opt, 'label.zh', ''),
                        'en' => (string) data_get($opt, 'label.en', ''),
                    ],
                    'score' => (float) ($opt['score'] ?? 0),
                ];
            }, (array) ($q['options'] ?? []));

            QuestionnaireQuestion::updateOrCreate(
                ['question_key' => $questionKey],
                [
                    'category' => (string) ($q['category'] ?? 'values'),
                    'content' => (string) data_get($q, 'question_text.zh', ''),
                    'question_text_zh' => (string) data_get($q, 'question_text.zh', ''),
                    'question_text_en' => (string) data_get($q, 'question_text.en', ''),
                    'question_type' => (string) ($q['answer_type'] ?? 'single_choice'),
                    'acceptable_answer_logic' => (string) ($q['acceptable_answer_logic'] ?? 'multi_select'),
                    'options' => $options,
                    'sort_order' => $sortOrder++,
                    'enabled' => (bool) ($q['active'] ?? true),
                    'version' => (int) ($q['version'] ?? 1),
                ]
            );
        }

        QuestionnaireQuestion::query()
            ->whereNotIn('question_key', $seenKeys)
            ->delete();
    }
}
