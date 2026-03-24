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
    private function quizLite3(): array
    {
        return [
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
        ];
    }

    public function quiz(Request $request): JsonResponse
    {
        $version = (string) $request->query('version', 'lite3_v1');
        if ($version !== 'lite3_v1') {
            return response()->json(['message' => 'unsupported version'], 422);
        }

        $questions = array_map(static function (array $q): array {
            return [
                'question_id' => $q['question_id'],
                'content' => $q['content'],
                'option_a_text' => $q['option_a_text'],
                'option_b_text' => $q['option_b_text'],
            ];
        }, $this->quizLite3());

        return response()->json([
            'version_code' => 'lite3_v1',
            'total' => count($questions),
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
            'answers' => ['required', 'array', 'size:3'],
            'answers.*.question_id' => ['required', 'integer', 'min:1', 'max:3'],
            'answers.*.option' => ['required', 'in:A,B'],
        ]);

        $version = (string) $data['version_code'];
        if ($version !== 'lite3_v1') {
            return response()->json(['message' => 'unsupported version'], 422);
        }

        $quiz = collect($this->quizLite3())->keyBy('question_id');
        $answers = collect($data['answers'])
            ->keyBy(static fn (array $a): int => (int) $a['question_id']);

        $keys = $answers->keys()->map(static fn ($v) => (int) $v)->sort()->values()->all();
        if ($answers->count() !== 3 || $keys !== [1, 2, 3]) {
            // keep deterministic message even if malformed payload passes schema checks
            return response()->json(['message' => 'invalid answers payload'], 422);
        }

        $score = ['E' => 0, 'I' => 0, 'S' => 0, 'N' => 0, 'T' => 0, 'F' => 0, 'J' => 0, 'P' => 0];
        foreach ([1, 2, 3] as $qid) {
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
