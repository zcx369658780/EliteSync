<?php

namespace App\Services;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;

class PersonalityProfileService
{
    public function buildForUser(int $userId): array
    {
        $dimensions = config('personality.dimensions', []);
        $scoringMap = config('personality.question_scoring', []);

        $questions = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->orderBy('sort_order')
            ->get(['id', 'question_key', 'options']);

        $answers = QuestionnaireAnswer::query()
            ->where('user_id', $userId)
            ->get(['questionnaire_question_id', 'answer_payload'])
            ->keyBy('questionnaire_question_id');

        $raw = array_fill_keys(array_keys($dimensions), 0.0);
        $answered = 0;

        foreach ($questions as $question) {
            $answer = $answers->get($question->id);
            if (!$answer) {
                continue;
            }

            $value = (string) data_get($answer->answer_payload, 'value', '');
            if ($value === '') {
                continue;
            }
            $answered++;

            $scoreRow = $scoringMap[$question->question_key][$value] ?? [];
            if (empty($scoreRow)) {
                $scoreRow = $this->fallbackScoreRow($question->options ?? [], $value);
            }
            foreach ($scoreRow as $dim => $delta) {
                if (array_key_exists($dim, $raw)) {
                    $raw[$dim] += (float) $delta;
                }
            }
        }

        $normalized = $this->normalizeScores($raw, $dimensions, $scoringMap);
        $summary = $this->summary($normalized, $dimensions);

        return [
            'answered' => $answered,
            'total' => $questions->count(),
            'complete' => $answered >= max(1, (int) config('questionnaire.required_answer_count', 10)),
            'vector' => $normalized,
            'summary' => $summary,
        ];
    }

    private function normalizeScores(array $raw, array $dimensions, array $scoringMap): array
    {
        $ranges = [];
        foreach (array_keys($dimensions) as $dim) {
            $min = 0.0;
            $max = 0.0;
            foreach ($scoringMap as $options) {
                $vals = [];
                foreach ($options as $optScore) {
                    $vals[] = (float) ($optScore[$dim] ?? 0);
                }
                $min += min($vals ?: [0.0]);
                $max += max($vals ?: [0.0]);
            }
            $ranges[$dim] = [$min, $max];
        }

        $normalized = [];
        foreach ($raw as $dim => $value) {
            [$min, $max] = $ranges[$dim];
            if ($max <= $min) {
                $normalized[$dim] = 50;
                continue;
            }
            $normalized[$dim] = (int) round((($value - $min) / ($max - $min)) * 100);
        }

        return $normalized;
    }

    private function summary(array $vector, array $dimensions): array
    {
        arsort($vector);
        $top = array_slice($vector, 0, 2, true);

        $highlights = [];
        foreach ($top as $dim => $score) {
            $highlights[] = ($dimensions[$dim] ?? $dim)." {$score}";
        }

        $topLabels = array_map(
            fn ($dim) => $dimensions[$dim] ?? $dim,
            array_keys($top)
        );
        $label = count($topLabels) >= 2
            ? sprintf('倾向：%s + %s', $topLabels[0], $topLabels[1])
            : '倾向：待测';

        return [
            'label' => $label,
            'highlights' => $highlights,
        ];
    }

    private function fallbackScoreRow(array $options, string $value): array
    {
        $opt = strtoupper(trim($value));
        if (!in_array($opt, ['A', 'B', 'C', 'D'], true)) {
            foreach (array_values($options) as $idx => $item) {
                $candidates = [];
                if (is_array($item)) {
                    $candidates[] = (string) data_get($item, 'option_id', '');
                    $candidates[] = (string) data_get($item, 'label.zh', '');
                    $candidates[] = (string) data_get($item, 'label.en', '');
                } else {
                    $candidates[] = (string) $item;
                }
                if (in_array($value, $candidates, true)) {
                    $opt = ['A', 'B', 'C', 'D'][$idx] ?? 'C';
                    break;
                }
            }
        }

        return match ($opt) {
            'A' => ['attachment_security' => 1, 'planning_style' => 1],
            'B' => ['emotional_stability' => 1, 'communication_directness' => 1],
            'C' => ['social_energy' => 1],
            'D' => ['social_energy' => -1, 'communication_directness' => -1],
            default => ['emotional_stability' => 0],
        };
    }
}
