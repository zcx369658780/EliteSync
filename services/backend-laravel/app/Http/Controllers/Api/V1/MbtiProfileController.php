<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MbtiAttempt;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MbtiProfileController extends Controller
{
    /**
     * @return array<int,array<string,mixed>>
     */
    private function quizItems(string $version): array
    {
        $sets = (array) config('mbti.quiz_sets', []);
        $items = (array) data_get($sets, $version.'.items', []);
        return array_values(array_filter($items, fn ($q) => is_array($q)));
    }

    private function defaultVersion(): string
    {
        return (string) config('mbti.default_version', 'lite3_v1');
    }

    public function quiz(Request $request): JsonResponse
    {
        $version = (string) $request->query('version', $this->defaultVersion());
        $itemsRaw = $this->quizItems($version);
        if (empty($itemsRaw)) {
            return response()->json(['message' => 'unsupported version'], 422);
        }

        $questions = array_map(static function (array $q): array {
            return [
                'question_id' => $q['question_id'],
                'content' => $q['content'],
                'option_a_text' => $q['option_a_text'],
                'option_b_text' => $q['option_b_text'],
            ];
        }, $itemsRaw);

        return response()->json([
            'version_code' => $version,
            'total' => count($questions),
            'available_versions' => array_keys((array) config('mbti.quiz_sets', [])),
            'items' => array_values($questions),
        ]);
    }

    public function result(Request $request): JsonResponse
    {
        $user = $request->user();
        $latest = MbtiAttempt::query()
            ->where('user_id', (int) $user->id)
            ->latest('id')
            ->first();

        // Canonical MBTI source is users.public_mbti (used by matching engine).
        // Attempt records are detail/history; if missing, still return persisted public_mbti.
        $userMbti = strtoupper((string) ($user->public_mbti ?? ''));
        if (!$latest) {
            if ($userMbti !== '') {
                return response()->json([
                    'exists' => true,
                    'result' => $userMbti,
                    'updated_at' => optional($user->updated_at)->toIso8601String(),
                    'scores' => null,
                    'confidence' => null,
                ]);
            }
            return response()->json([
                'exists' => false,
                'result' => null,
                'updated_at' => null,
                'scores' => null,
                'confidence' => null,
            ]);
        }

        $result = strtoupper((string) ($latest->result_letters ?? ''));
        if ($result === '' && $userMbti !== '') {
            $result = $userMbti;
        }

        return response()->json([
            'exists' => true,
            'result' => $result,
            'updated_at' => optional($latest->submitted_at ?? $latest->created_at)->toIso8601String(),
            'scores' => $latest->score_json ?? [],
            'confidence' => $latest->confidence_json ?? [],
        ]);
    }

    public function submit(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'version_code' => ['required', 'string', 'max:32'],
            'answers' => ['required', 'array', 'min:1'],
            'answers.*.question_id' => ['required', 'integer', 'min:1'],
            'answers.*.option' => ['required', 'in:A,B'],
        ]);

        $version = (string) $data['version_code'];
        $quizItems = $this->quizItems($version);
        if (empty($quizItems)) {
            return response()->json(['message' => 'unsupported version'], 422);
        }

        $quiz = collect($quizItems)->keyBy('question_id');
        $answers = collect($data['answers'])
            ->keyBy(static fn (array $a): int => (int) $a['question_id']);

        $expectedIds = $quiz->keys()->map(fn ($v) => (int) $v)->sort()->values()->all();
        $keys = $answers->keys()->map(static fn ($v): int => (int) $v)->sort()->values()->all();
        if ($answers->count() !== count($expectedIds) || $keys !== $expectedIds) {
            // keep deterministic message even if malformed payload passes schema checks
            return response()->json(['message' => 'invalid answers payload'], 422);
        }

        $score = ['E' => 0, 'I' => 0, 'S' => 0, 'N' => 0, 'T' => 0, 'F' => 0, 'J' => 0, 'P' => 0];
        foreach ($expectedIds as $qid) {
            $option = (string) (($answers->get($qid) ?? [])['option'] ?? '');
            $mapping = (array) (($quiz->get($qid) ?? [])['mapping'][$option] ?? []);
            foreach ($mapping as $k => $v) {
                $score[$k] = (int) $score[$k] + (int) $v;
            }
        }

        $tieBreak = [];
        $latestMbti = strtoupper((string) ($user->public_mbti ?? ''));
        $pairs = [
            'EI' => ['E', 'I'],
            'SN' => ['S', 'N'],
            'TF' => ['T', 'F'],
            'JP' => ['J', 'P'],
        ];

        $letters = [];
        $confidence = [];
        foreach ($pairs as $dim => [$a, $b]) {
            $av = (int) ($score[$a] ?? 0);
            $bv = (int) ($score[$b] ?? 0);
            $sum = max(1, $av + $bv);
            $confidence[$dim] = round(abs($av - $bv) / $sum, 3);

            if ($av > $bv) {
                $letters[$dim] = $a;
                continue;
            }
            if ($bv > $av) {
                $letters[$dim] = $b;
                continue;
            }

            $idx = match ($dim) {
                'EI' => 0,
                'SN' => 1,
                'TF' => 2,
                default => 3,
            };
            if (strlen($latestMbti) === 4) {
                $c = $latestMbti[$idx];
                if ($c === $a || $c === $b) {
                    $letters[$dim] = $c;
                    $tieBreak[$dim] = 'history';
                    continue;
                }
            }

            $stable = crc32(((string) $user->id) . ':' . $dim);
            $letters[$dim] = (($stable % 2) === 0) ? $a : $b;
            $tieBreak[$dim] = 'stable_hash';
        }

        $result = $letters['EI'] . $letters['SN'] . $letters['TF'] . $letters['JP'];

        DB::transaction(function () use ($user, $version, $data, $score, $confidence, $tieBreak, $result): void {
            MbtiAttempt::query()->create([
                'user_id' => (int) $user->id,
                'version_code' => $version,
                'answers_json' => array_values($data['answers']),
                'score_json' => $score,
                'confidence_json' => $confidence,
                'tie_break_log_json' => $tieBreak,
                'result_letters' => $result,
                'submitted_at' => now(),
            ]);

            $personality = (array) ($user->public_personality ?? []);
            $personality['mbti'] = [
                'result' => $result,
                'confidence' => $confidence,
                'version_code' => $version,
                'updated_at' => now()->toIso8601String(),
            ];

            $user->forceFill([
                'public_mbti' => $result,
                'public_personality' => $personality,
            ])->save();
        });

        return response()->json([
            'ok' => true,
            'result' => $result,
            'letters' => $letters,
            'scores' => $score,
            'confidence' => $confidence,
        ]);
    }
}
