<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireAttempt;
use App\Models\QuestionnaireQuestion;
use App\Services\PersonalityProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class QuestionnaireController extends Controller
{
    private const IMPORTANCE_WEIGHT = [
        0 => 0.0,
        1 => 0.33,
        2 => 0.66,
        3 => 1.0,
    ];

    private function requiredAnswerCount(): int
    {
        return max(1, (int) config('questionnaire.required_answer_count', 10));
    }

    private function questionnaireVersion(): string
    {
        return (string) config('questionnaire.version', 'q_v2');
    }

    private function bankVersion(): string
    {
        return (string) config('questionnaire.bank_version', 'qb_v1');
    }

    private function attemptVersion(): string
    {
        return (string) config('questionnaire.attempt_version', 'qa_v1');
    }

    private function questionnaireLabel(): string
    {
        return (string) config('questionnaire.label', '非官方人格四维问卷');
    }

    private function nonOfficialNotice(): string
    {
        return (string) config(
            'questionnaire.non_official_notice',
            '仅用于产品内人格倾向参考，不代表官方 MBTI。'
        );
    }

    private function estimatedMinutes(): int
    {
        return max(1, (int) config('questionnaire.estimated_minutes', 6));
    }

    private function sessionQuestionCount(): int
    {
        return max(1, (int) config('questionnaire.session_question_count', 10));
    }

    public function questions(Request $request): JsonResponse
    {
        $user = $request->user();
        $answeredIds = QuestionnaireAnswer::query()
            ->where('user_id', $user->id)
            ->distinct('questionnaire_question_id')
            ->pluck('questionnaire_question_id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $baseQuery = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->whereIn('quality_tier', $this->allowedQualityTiers())
            ->whereIn('quality_tag', $this->primaryQualityTags())
            ->whereNotIn('id', $answeredIds);

        $sessionCount = $this->sessionQuestionCount();
        $mix = (array) config('questionnaire.bank_mix_ratio', []);
        $targets = $this->buildMixTargets($sessionCount, $mix);
        $questions = collect();

        foreach ($targets as $bank => $count) {
            if ($count <= 0) {
                continue;
            }
            $part = (clone $baseQuery)
                ->where('recommended_bank', $bank)
                ->inRandomOrder()
                ->limit($count)
                ->get([
                    'id',
                    'question_key',
                    'category',
                    'subtopic',
                    'recommended_bank',
                    'quality_tier',
                    'quality_tag',
                    'content',
                    'question_text_zh',
                    'question_text_en',
                    'question_type',
                    'acceptable_answer_logic',
                    'options',
                    'version',
                ]);
            $questions = $questions->concat($part);
        }

        if ($questions->count() < $sessionCount) {
            $fill = (clone $baseQuery)
                ->whereNotIn('id', $questions->pluck('id')->all())
                ->inRandomOrder()
                ->limit($sessionCount - $questions->count())
                ->get([
                    'id',
                    'question_key',
                    'category',
                    'subtopic',
                    'recommended_bank',
                    'quality_tier',
                    'quality_tag',
                    'content',
                    'question_text_zh',
                    'question_text_en',
                    'question_type',
                    'acceptable_answer_logic',
                    'options',
                    'version',
                ]);
            $questions = $questions->concat($fill);
        }

        if ($questions->count() < $sessionCount) {
            $fallback = QuestionnaireQuestion::query()
                ->where('enabled', true)
                ->whereIn('quality_tag', $this->fallbackQualityTags())
                ->whereNotIn('id', $questions->pluck('id')->all())
                ->whereNotIn('id', $answeredIds)
                ->inRandomOrder()
                ->limit($sessionCount - $questions->count())
                ->get([
                    'id',
                    'question_key',
                    'category',
                    'subtopic',
                    'recommended_bank',
                    'quality_tier',
                    'quality_tag',
                    'content',
                    'question_text_zh',
                    'question_text_en',
                    'question_type',
                    'acceptable_answer_logic',
                    'options',
                    'version',
                ]);
            $questions = $questions->concat($fallback);
        }

        $questions = $questions->shuffle()->values();
        $questions = $questions->map(function (QuestionnaireQuestion $q) {
            return [
                'id' => $q->id,
                'question_key' => $q->question_key,
                'category' => $q->category,
                'subtopic' => $q->subtopic,
                'recommended_bank' => $q->recommended_bank,
                'questionnaire_version' => $this->questionnaireVersion(),
                'bank_version' => $this->bankVersion(),
                'quality_tier' => $q->quality_tier,
                'quality_tag' => $q->quality_tag,
                'content' => $q->question_text_zh ?: $q->content,
                'question_type' => $q->question_type,
                'acceptable_answer_logic' => $q->acceptable_answer_logic,
                'measured_dimensions' => collect($q->options ?? [])
                    ->flatMap(fn ($opt) => array_keys((array) data_get($opt, 'dimension_weights', [])))
                    ->unique()
                    ->values(),
                // legacy field shape for Android V1: plain labels
                'options' => collect($q->options ?? [])->map(
                    fn ($opt) => (string) data_get($opt, 'label.zh', '')
                )->values(),
                // V2 rich options
                'option_items' => collect($q->options ?? [])->map(function ($opt) {
                    return [
                        'option_id' => (string) data_get($opt, 'option_id', ''),
                        'label' => [
                            'zh' => (string) data_get($opt, 'label.zh', ''),
                            'en' => (string) data_get($opt, 'label.en', ''),
                        ],
                        'evaluation_standard' => [
                            'code' => (string) data_get($opt, 'evaluation_standard.code', ''),
                            'zh' => (string) data_get($opt, 'evaluation_standard.zh', ''),
                            'en' => (string) data_get($opt, 'evaluation_standard.en', ''),
                        ],
                        'dimension_weights' => (array) data_get($opt, 'dimension_weights', []),
                        'score' => (float) data_get($opt, 'score', 0),
                    ];
                })->values(),
                'version' => $q->version ?? 1,
                'question_version' => (int) ($q->version ?? 1),
            ];
        });

        $bankTotal = QuestionnaireQuestion::query()->where('enabled', true)->count();

        return response()->json([
            'meta' => [
                'version' => $this->questionnaireVersion(),
                'bank_version' => $this->bankVersion(),
                'attempt_version' => $this->attemptVersion(),
                'label' => $this->questionnaireLabel(),
                'non_official_notice' => $this->nonOfficialNotice(),
                'estimated_minutes' => $this->estimatedMinutes(),
                'required_answers' => $this->requiredAnswerCount(),
                'session_questions' => $this->sessionQuestionCount(),
            ],
            'items' => $questions,
            'total' => $questions->count(),
            'bank_total' => $bankTotal,
            'required' => $this->requiredAnswerCount(),
            'importance_mapping' => self::IMPORTANCE_WEIGHT,
        ]);
    }

    public function replaceQuestion(Request $request): JsonResponse
    {
        $data = $request->validate([
            'exclude_ids' => ['required', 'array'],
            'exclude_ids.*' => ['integer'],
        ]);

        $user = $request->user();
        $answeredIds = QuestionnaireAnswer::query()
            ->where('user_id', $user->id)
            ->distinct('questionnaire_question_id')
            ->pluck('questionnaire_question_id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $excludeIds = collect($data['exclude_ids'])
            ->map(fn ($id) => (int) $id)
            ->merge($answeredIds)
            ->unique()
            ->values()
            ->all();

        $next = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->whereIn('quality_tier', $this->allowedQualityTiers())
            ->whereIn('quality_tag', $this->primaryQualityTags())
            ->whereNotIn('id', $excludeIds)
            ->inRandomOrder()
            ->first([
                'id',
                'question_key',
                'category',
                'subtopic',
                'recommended_bank',
                'quality_tier',
                'quality_tag',
                'content',
                'question_text_zh',
                'question_type',
                'acceptable_answer_logic',
                'options',
                'version',
            ]);

        if (!$next) {
            $next = QuestionnaireQuestion::query()
                ->where('enabled', true)
                ->whereIn('quality_tag', $this->fallbackQualityTags())
                ->whereNotIn('id', $excludeIds)
                ->inRandomOrder()
                ->first([
                    'id',
                    'question_key',
                    'category',
                    'subtopic',
                    'recommended_bank',
                    'quality_tier',
                    'quality_tag',
                    'content',
                    'question_text_zh',
                    'question_type',
                    'acceptable_answer_logic',
                    'options',
                    'version',
                ]);
        }

        if (!$next) {
            return response()->json(['message' => 'no replacement question'], 404);
        }

        return response()->json([
            'id' => $next->id,
            'question_key' => $next->question_key,
            'category' => $next->category,
            'subtopic' => $next->subtopic,
            'recommended_bank' => $next->recommended_bank,
            'questionnaire_version' => $this->questionnaireVersion(),
            'bank_version' => $this->bankVersion(),
            'quality_tier' => $next->quality_tier,
            'quality_tag' => $next->quality_tag,
            'content' => $next->question_text_zh ?: $next->content,
            'question_type' => $next->question_type,
            'acceptable_answer_logic' => $next->acceptable_answer_logic,
            'measured_dimensions' => collect($next->options ?? [])
                ->flatMap(fn ($opt) => array_keys((array) data_get($opt, 'dimension_weights', [])))
                ->unique()
                ->values(),
            'options' => collect($next->options ?? [])->map(
                fn ($opt) => (string) data_get($opt, 'label.zh', '')
            )->values(),
            'option_items' => collect($next->options ?? [])->map(function ($opt) {
                return [
                    'option_id' => (string) data_get($opt, 'option_id', ''),
                    'label' => [
                        'zh' => (string) data_get($opt, 'label.zh', ''),
                        'en' => (string) data_get($opt, 'label.en', ''),
                    ],
                    'evaluation_standard' => [
                        'code' => (string) data_get($opt, 'evaluation_standard.code', ''),
                        'zh' => (string) data_get($opt, 'evaluation_standard.zh', ''),
                        'en' => (string) data_get($opt, 'evaluation_standard.en', ''),
                    ],
                    'dimension_weights' => (array) data_get($opt, 'dimension_weights', []),
                    'score' => (float) data_get($opt, 'score', 0),
                ];
            })->values(),
            'version' => $next->version ?? 1,
            'question_version' => (int) ($next->version ?? 1),
        ]);
    }

    public function submitAnswers(Request $request, PersonalityProfileService $profiles): JsonResponse
    {
        $payload = $request->all();
        $payload['answers'] = $this->normalizeLegacyAnswersPayload($payload['answers'] ?? []);

        $data = validator($payload, [
            'answers' => ['required', 'array', 'min:1'],
            'answers.*.question_id' => ['required', 'integer', 'exists:questionnaire_questions,id'],
            // legacy payload
            'answers.*.answer' => ['nullable'],
            // v2 payload
            'answers.*.selected_answer' => ['nullable', 'array', 'min:1'],
            'answers.*.selected_answer.*' => ['string'],
            'answers.*.acceptable_answers' => ['nullable', 'array', 'min:1'],
            'answers.*.acceptable_answers.*' => ['string'],
            'answers.*.importance' => ['nullable', 'integer', 'between:0,3'],
            'answers.*.version' => ['nullable', 'integer', 'min:1'],
        ])->validate();

        $user = $request->user();
        $questionIds = collect($data['answers'])
            ->pluck('question_id')
            ->map(fn ($id) => (int) $id)
            ->all();
        $questionMap = QuestionnaireQuestion::query()
            ->whereIn('id', $questionIds)
            ->get(['id', 'question_key', 'version'])
            ->keyBy('id');

        foreach ($data['answers'] as $item) {
            $selected = $this->normalizeSelectedAnswer($item);
            if (count($selected) === 0) {
                throw ValidationException::withMessages([
                    'answers' => ['selected_answer or answer is required'],
                ]);
            }
            $acceptable = $this->normalizeAcceptableAnswers($item, $selected);
            $importance = $this->normalizeImportance($item);
            $question = $questionMap->get((int) $item['question_id']);
            $questionVersion = (int) ($question->version ?? 1);

            QuestionnaireAnswer::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'questionnaire_question_id' => $item['question_id'],
                ],
                [
                    'answer_payload' => [
                        'value' => $selected[0] ?? '',
                        'selected_answer' => $selected,
                        'acceptable_answers' => $acceptable,
                        'importance' => $importance,
                        'importance_weight' => self::IMPORTANCE_WEIGHT[$importance],
                        'version' => (int) ($item['version'] ?? 1),
                        'question_key' => (string) ($question->question_key ?? ''),
                        'question_version' => $questionVersion,
                        'questionnaire_version' => $this->questionnaireVersion(),
                        'bank_version' => $this->bankVersion(),
                        'attempt_version' => $this->attemptVersion(),
                    ],
                    'selected_answer_json' => $selected,
                    'acceptable_answers_json' => $acceptable,
                    'importance' => $importance,
                    'version' => (int) ($item['version'] ?? 1),
                ],
            );
        }

        $profile = $profiles->buildForUser((int) $user->id);
        $questionCount = QuestionnaireQuestion::query()->where('enabled', true)->count();
        QuestionnaireAttempt::query()->create([
            'user_id' => (int) $user->id,
            'questionnaire_version' => $this->questionnaireVersion(),
            'bank_version' => $this->bankVersion(),
            'attempt_version' => $this->attemptVersion(),
            'answers_count' => count($data['answers']),
            'total_count' => $questionCount,
            'answers_json' => array_values($data['answers']),
            'profile_json' => $profile,
            'summary_json' => (array) data_get($profile, 'summary', []),
            'result_label' => (string) data_get($profile, 'summary.label', ''),
            'result_highlights_json' => (array) data_get($profile, 'summary.highlights', []),
            'completed_at' => now(),
        ]);

        return response()->json([
            'ok' => true,
            'questionnaire_version' => $this->questionnaireVersion(),
            'bank_version' => $this->bankVersion(),
            'attempt_version' => $this->attemptVersion(),
            'profile' => $profile,
        ]);
    }

    public function history(Request $request): JsonResponse
    {
        $user = $request->user();
        $items = QuestionnaireAttempt::query()
            ->where('user_id', (int) $user->id)
            ->orderByDesc('id')
            ->limit(20)
            ->get();

        return response()->json([
            'items' => $items->map(function (QuestionnaireAttempt $attempt): array {
                return [
                    'id' => $attempt->id,
                    'questionnaire_version' => $attempt->questionnaire_version,
                    'bank_version' => $attempt->bank_version,
                    'attempt_version' => $attempt->attempt_version,
                    'answers_count' => $attempt->answers_count,
                    'total_count' => $attempt->total_count,
                    'result_label' => $attempt->result_label,
                    'result_highlights' => $attempt->result_highlights_json ?? [],
                    'summary' => $attempt->summary_json ?? [],
                    'profile_complete' => (bool) data_get($attempt->profile_json, 'complete', false),
                    'completed_at' => optional($attempt->completed_at)->toIso8601String(),
                ];
            })->values(),
            'total' => $items->count(),
        ]);
    }

    public function saveDraftLegacy(Request $request): JsonResponse
    {
        // Draft persistence is now handled client-side.
        // Keep endpoint for legacy clients to avoid hard failure.
        return response()->json(['ok' => true, 'legacy' => true]);
    }

    public function progress(Request $request): JsonResponse
    {
        $user = $request->user();
        $answered = QuestionnaireAnswer::query()
            ->where('user_id', $user->id)
            ->distinct('questionnaire_question_id')
            ->count('questionnaire_question_id');
        $total = $this->requiredAnswerCount();

        return response()->json([
            'answered' => $answered,
            'total' => $total,
            'complete' => $total > 0 && $answered >= $total,
        ]);
    }

    public function profile(Request $request, PersonalityProfileService $service): JsonResponse
    {
        $user = $request->user();
        return response()->json($service->buildForUser((int) $user->id));
    }

    public function reset(Request $request): JsonResponse
    {
        $user = $request->user();
        QuestionnaireAnswer::query()
            ->where('user_id', (int) $user->id)
            ->delete();

        return response()->json(['ok' => true]);
    }

    private function normalizeSelectedAnswer(array $item): array
    {
        $selected = $item['selected_answer'] ?? null;
        if (is_array($selected) && count($selected) > 0) {
            return array_values(array_map('strval', $selected));
        }
        if (array_key_exists('answer', $item) && $item['answer'] !== null && $item['answer'] !== '') {
            return [(string) $item['answer']];
        }
        return [];
    }

    /**
     * Legacy format support:
     * - map: { "12": 3, "15": 1 }
     * - list (already normalized): [{question_id: 12, answer: "3"}]
     */
    private function normalizeLegacyAnswersPayload(mixed $raw): array
    {
        if (!is_array($raw)) {
            return [];
        }

        if (array_is_list($raw)) {
            return array_values(array_filter($raw, fn ($row) => is_array($row)));
        }

        $out = [];
        foreach ($raw as $qid => $answer) {
            if (!is_numeric($qid)) {
                continue;
            }
            $out[] = [
                'question_id' => (int) $qid,
                'answer' => (string) $answer,
                'importance' => 2,
                'version' => 1,
            ];
        }
        return $out;
    }

    private function normalizeAcceptableAnswers(array $item, array $selected): array
    {
        $acceptable = $item['acceptable_answers'] ?? null;
        if (is_array($acceptable) && count($acceptable) > 0) {
            return array_values(array_map('strval', $acceptable));
        }
        return $selected;
    }

    private function normalizeImportance(array $item): int
    {
        $importance = (int) ($item['importance'] ?? 2);
        return max(0, min(3, $importance));
    }

    /**
     * @param array<string,float|int> $mix
     * @return array<string,int>
     */
    private function buildMixTargets(int $total, array $mix): array
    {
        $banks = ['core', 'extended', 'research'];
        $weights = [];
        foreach ($banks as $bank) {
            $weights[$bank] = max(0.0, (float) ($mix[$bank] ?? 0.0));
        }
        $sum = array_sum($weights);
        if ($sum <= 0) {
            return ['core' => $total, 'extended' => 0, 'research' => 0];
        }

        $targets = [];
        $assigned = 0;
        foreach ($banks as $bank) {
            $targets[$bank] = (int) floor(($weights[$bank] / $sum) * $total);
            $assigned += $targets[$bank];
        }
        $order = collect($banks)
            ->sortByDesc(fn ($b) => $weights[$b])
            ->values()
            ->all();
        $idx = 0;
        while ($assigned < $total) {
            $bank = $order[$idx % count($order)];
            $targets[$bank]++;
            $assigned++;
            $idx++;
        }

        return $targets;
    }

    /**
     * @return array<int,string>
     */
    private function allowedQualityTiers(): array
    {
        $tiers = array_values(array_filter(
            array_map('strval', (array) config('questionnaire.allowed_quality_tiers', ['high', 'normal']))
        ));

        return empty($tiers) ? ['high', 'normal'] : $tiers;
    }

    /**
     * @return array<int,string>
     */
    private function primaryQualityTags(): array
    {
        $tags = array_values(array_filter(
            array_map('strval', (array) config('questionnaire.primary_quality_tags', ['pass', 'low_keep']))
        ));

        return empty($tags) ? ['pass', 'low_keep'] : $tags;
    }

    /**
     * @return array<int,string>
     */
    private function fallbackQualityTags(): array
    {
        $tags = array_values(array_filter(
            array_map('strval', (array) config('questionnaire.fallback_quality_tags', ['pass', 'low_keep', 'low_drop']))
        ));

        return empty($tags) ? ['pass', 'low_keep', 'low_drop'] : $tags;
    }
}
