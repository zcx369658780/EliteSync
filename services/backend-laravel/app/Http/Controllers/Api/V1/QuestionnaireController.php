<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\QuestionnaireAnswer;
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

        $questions = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->whereNotIn('id', $answeredIds)
            ->inRandomOrder()
            ->limit($this->sessionQuestionCount())
            ->get([
                'id',
                'question_key',
                'category',
                'content',
                'question_text_zh',
                'question_text_en',
                'question_type',
                'acceptable_answer_logic',
                'options',
                'version',
            ]);

        $bankTotal = QuestionnaireQuestion::query()->where('enabled', true)->count();

        return response()->json([
            'items' => $questions->map(function (QuestionnaireQuestion $q) {
                return [
                    'id' => $q->id,
                    'question_key' => $q->question_key,
                    'category' => $q->category,
                    'content' => $q->question_text_zh ?: $q->content,
                    'question_type' => $q->question_type,
                    'acceptable_answer_logic' => $q->acceptable_answer_logic,
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
                            'score' => (float) data_get($opt, 'score', 0),
                        ];
                    })->values(),
                    'version' => $q->version ?? 1,
                ];
            })->values(),
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
            ->whereNotIn('id', $excludeIds)
            ->inRandomOrder()
            ->first([
                'id',
                'question_key',
                'category',
                'content',
                'question_text_zh',
                'question_type',
                'acceptable_answer_logic',
                'options',
                'version',
            ]);

        if (!$next) {
            return response()->json(['message' => 'no replacement question'], 404);
        }

        return response()->json([
            'id' => $next->id,
            'question_key' => $next->question_key,
            'category' => $next->category,
            'content' => $next->question_text_zh ?: $next->content,
            'question_type' => $next->question_type,
            'acceptable_answer_logic' => $next->acceptable_answer_logic,
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
                    'score' => (float) data_get($opt, 'score', 0),
                ];
            })->values(),
            'version' => $next->version ?? 1,
        ]);
    }

    public function submitAnswers(Request $request): JsonResponse
    {
        $data = $request->validate([
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
        ]);

        $user = $request->user();

        foreach ($data['answers'] as $item) {
            $selected = $this->normalizeSelectedAnswer($item);
            if (count($selected) === 0) {
                throw ValidationException::withMessages([
                    'answers' => ['selected_answer or answer is required'],
                ]);
            }
            $acceptable = $this->normalizeAcceptableAnswers($item, $selected);
            $importance = $this->normalizeImportance($item);

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
                    ],
                    'selected_answer_json' => $selected,
                    'acceptable_answers_json' => $acceptable,
                    'importance' => $importance,
                    'version' => (int) ($item['version'] ?? 1),
                ],
            );
        }

        return response()->json(['ok' => true]);
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
}
