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

        $normalized = $this->normalizeScores($raw, $dimensions, $scoringMap, $questions->all());
        $summary = $this->summary($normalized, $dimensions);

        return [
            'answered' => $answered,
            'total' => $questions->count(),
            'complete' => $answered >= max(1, (int) config('questionnaire.required_answer_count', 10)),
            'vector' => $normalized,
            'summary' => $summary,
        ];
    }

    private function normalizeScores(array $raw, array $dimensions, array $scoringMap, array $questions): array
    {
        $ranges = $this->computeRanges($dimensions, $scoringMap, $questions);

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

    private function computeRanges(array $dimensions, array $scoringMap, array $questions): array
    {
        $ranges = [];
        foreach (array_keys($dimensions) as $dim) {
            $ranges[$dim] = [0.0, 0.0];
        }

        foreach ($questions as $question) {
            $rowSet = [];

            $options = (array) ($question->options ?? []);
            foreach ($options as $opt) {
                $weights = data_get($opt, 'dimension_weights');
                if (is_array($weights) && !empty($weights)) {
                    $rowSet[] = $weights;
                }
            }

            if (empty($rowSet)) {
                $legacyRows = (array) ($scoringMap[$question->question_key] ?? []);
                foreach ($legacyRows as $legacy) {
                    if (is_array($legacy)) {
                        $rowSet[] = $legacy;
                    }
                }
            }

            if (empty($rowSet)) {
                continue;
            }

            foreach (array_keys($dimensions) as $dim) {
                $vals = [];
                foreach ($rowSet as $row) {
                    $vals[] = (float) ($row[$dim] ?? 0.0);
                }
                $ranges[$dim][0] += min($vals);
                $ranges[$dim][1] += max($vals);
            }
        }

        return $ranges;
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
        $matched = null;
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
                    $matched = $item;
                    break;
                }
            }
        }

        if ($matched === null) {
            foreach (array_values($options) as $item) {
                if ((string) data_get($item, 'option_id', '') === $opt) {
                    $matched = $item;
                    break;
                }
            }
        }
        if (is_array($matched)) {
            $weights = data_get($matched, 'dimension_weights');
            if (is_array($weights) && !empty($weights)) {
                return $weights;
            }
        }

        return match ($opt) {
            'A' => ['attachment_security' => 0.6, 'communication_clarity' => 0.5],
            'B' => ['emotional_regulation' => 0.5, 'planning_reliability' => 0.4],
            'C' => ['social_initiative' => 0.4, 'openness_exploration' => 0.3],
            'D' => ['attachment_security' => -0.4, 'rejection_resilience' => -0.5],
            default => ['emotional_regulation' => 0.0],
        };
    }
}
