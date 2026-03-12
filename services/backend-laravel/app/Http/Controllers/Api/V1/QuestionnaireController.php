<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QuestionnaireController extends Controller
{
    public function questions(): JsonResponse
    {
        $questions = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->orderBy('sort_order')
            ->get(['id', 'question_key', 'content', 'question_type', 'options']);

        return response()->json([
            'items' => $questions,
            'total' => $questions->count(),
        ]);
    }

    public function submitAnswers(Request $request): JsonResponse
    {
        $data = $request->validate([
            'answers' => ['required', 'array', 'min:1'],
            'answers.*.question_id' => ['required', 'integer', 'exists:questionnaire_questions,id'],
            'answers.*.answer' => ['required'],
        ]);

        $user = $request->user();

        foreach ($data['answers'] as $item) {
            QuestionnaireAnswer::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'questionnaire_question_id' => $item['question_id'],
                ],
                [
                    'answer_payload' => ['value' => $item['answer']],
                ],
            );
        }

        return response()->json(['ok' => true]);
    }

    public function progress(Request $request): JsonResponse
    {
        $user = $request->user();
        $answered = QuestionnaireAnswer::where('user_id', $user->id)->count();
        $total = QuestionnaireQuestion::where('enabled', true)->count();

        return response()->json([
            'answered' => $answered,
            'total' => $total,
            'complete' => $total > 0 && $answered >= $total,
        ]);
    }
}
