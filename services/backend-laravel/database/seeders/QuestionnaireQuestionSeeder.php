<?php

namespace Database\Seeders;

use App\Models\QuestionnaireQuestion;
use Illuminate\Database\Seeder;
use RuntimeException;

class QuestionnaireQuestionSeeder extends Seeder
{
    public function run(): void
    {
        $banks = $this->loadQuestionBanks();

        $seenKeys = [];
        $sortOrder = 1;

        foreach ($banks as $q) {
            $questionKey = (string) ($q['question_id'] ?? '');
            if ($questionKey === '' && isset($q['source_question_no'])) {
                $sourceNo = (int) $q['source_question_no'];
                if ($sourceNo > 0) {
                    $questionKey = sprintf('Q_DOCX_V2_%03d', $sourceNo);
                }
            }
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
                    'dimension_weights' => (array) ($opt['dimension_weights'] ?? []),
                    'evaluation_standard' => [
                        'code' => (string) data_get($opt, 'evaluation_standard.code', ''),
                        'zh' => (string) data_get($opt, 'evaluation_standard.zh', ''),
                        'en' => (string) data_get($opt, 'evaluation_standard.en', ''),
                    ],
                    'score' => (float) ($opt['score'] ?? 0),
                ];
            }, (array) ($q['options'] ?? []));

            QuestionnaireQuestion::updateOrCreate(
                ['question_key' => $questionKey],
                [
                    'category' => (string) ($q['category'] ?? 'values'),
                    'subtopic' => (string) ($q['subtopic'] ?? ''),
                    'recommended_bank' => (string) ($q['recommended_bank'] ?? 'core'),
                    'quality_tier' => (string) ($q['quality_tier'] ?? 'normal'),
                    'quality_tag' => (string) ($q['quality_tag'] ?? 'pass'),
                    'quality_reason' => (string) data_get($q, 'quality_meta.reason', 'standard_discrimination'),
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

    /**
     * @return array<int,array<string,mixed>>
     */
    private function loadQuestionBanks(): array
    {
        $root = base_path('..'.DIRECTORY_SEPARATOR.'..');
        $dir = realpath($root.DIRECTORY_SEPARATOR.'question_bank');
        $files = [];
        if ($dir && is_dir($dir)) {
            $files = glob($dir.DIRECTORY_SEPARATOR.'question_bank_*.json') ?: [];
        }

        // fallback to legacy single file if split banks are absent
        if (empty($files)) {
            $legacy = realpath($root.DIRECTORY_SEPARATOR.'dating_question_bank_v_1.json');
            if ($legacy && is_file($legacy)) {
                $files = [$legacy];
            }
        }

        if (empty($files)) {
            throw new RuntimeException('question bank json files not found');
        }

        $all = [];
        foreach ($files as $file) {
            $raw = file_get_contents($file);
            $payload = json_decode((string) $raw, true);
            if (!is_array($payload) || !isset($payload['questions']) || !is_array($payload['questions'])) {
                continue;
            }
            $inferredBank = str_contains((string) $file, 'extended') ? 'extended'
                : (str_contains((string) $file, 'research') ? 'research' : 'core');
            foreach ($payload['questions'] as $q) {
                if (!isset($q['recommended_bank'])) {
                    $q['recommended_bank'] = $inferredBank;
                }
                $all[] = $q;
            }
        }

        if (empty($all)) {
            throw new RuntimeException('no valid questions loaded from question bank files');
        }
        return $all;
    }
}
