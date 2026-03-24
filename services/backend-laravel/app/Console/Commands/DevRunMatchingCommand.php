<?php

namespace App\Console\Commands;

use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\MatchingDebugModeService;
use App\Services\MatchingEngineService;
use App\Services\PersonalityProfileService;
use Illuminate\Console\Command;

class DevRunMatchingCommand extends Command
{
    protected $signature = 'app:dev:run-matching
        {--include-synthetic= : Force include synthetic users (1/0). If omitted, use debug switch}
        {--release-drop : Mark this week matches as drop_released=true after matching}
        {--reset-week : Delete this week existing matches before rerun}';

    protected $description = 'Run matching in CLI mode for larger synthetic batches without HTTP timeout.';

    public function handle(
        PersonalityProfileService $profileService,
        MatchingEngineService $matchingEngine,
        MatchingDebugModeService $debugMode
    ): int {
        @set_time_limit(0);
        @ini_set('max_execution_time', '0');

        $weekTag = now()->utc()->format('Y-\WW');
        $totalQuestions = QuestionnaireQuestion::query()->where('enabled', true)->count();
        $requiredAnswers = max(1, (int) config('questionnaire.required_answer_count', 10));
        $includeOption = $this->option('include-synthetic');
        $includeSyntheticUsers = $includeOption === null
            ? $debugMode->includeSyntheticUsers()
            : in_array((string) $includeOption, ['1', 'true', 'yes', 'on'], true);

        if ($totalQuestions === 0) {
            $this->warn('No enabled questions, skip matching.');
            return self::SUCCESS;
        }

        if ((bool) $this->option('reset-week')) {
            $deleted = DatingMatch::query()->where('week_tag', $weekTag)->delete();
            $this->line("reset-week deleted={$deleted}");
        }

        $eligibleUserIds = QuestionnaireAnswer::query()
            ->select('user_id')
            ->groupBy('user_id')
            ->havingRaw('COUNT(DISTINCT questionnaire_question_id) >= ?', [$requiredAnswers]);

        $users = User::query()
            ->where('disabled', false)
            ->when(!$includeSyntheticUsers, function ($q) {
                $q->where('is_synthetic', false);
            })
            ->whereIn('id', $eligibleUserIds)
            ->orderBy('id')
            ->get(['id', 'created_at', 'updated_at']);

        $profiles = [];
        $usersMeta = [];
        foreach ($users as $u) {
            $profiles[(int) $u->id] = $profileService->buildForUser((int) $u->id);
            $usersMeta[(int) $u->id] = [
                'created_at' => $u->created_at,
                'updated_at' => $u->updated_at,
            ];
        }

        $plannedPairs = $matchingEngine->buildPairs($profiles, $usersMeta);
        $pairsCreated = 0;
        $pairsExisting = 0;
        $createdMatchIds = [];

        foreach ($plannedPairs as $plannedPair) {
            $a = (int) $plannedPair['user_a'];
            $b = (int) $plannedPair['user_b'];

            $exists = DatingMatch::query()
                ->where('week_tag', $weekTag)
                ->where(function ($q) use ($a, $b) {
                    $q->where(function ($pair) use ($a, $b) {
                        $pair->where('user_a', $a)->where('user_b', $b);
                    })->orWhere(function ($pair) use ($a, $b) {
                        $pair->where('user_a', $b)->where('user_b', $a);
                    });
                })
                ->first();

            if ($exists) {
                $pairsExisting++;
                $createdMatchIds[] = (int) $exists->id;
                continue;
            }

            $match = DatingMatch::create([
                'week_tag' => $weekTag,
                'user_a' => $a,
                'user_b' => $b,
                'highlights' => (string) $plannedPair['highlights'],
                'explanation_tags' => $plannedPair['explanation_tags'] ?? null,
                'score_base' => $plannedPair['score_base'] ?? null,
                'score_final' => $plannedPair['score_final'] ?? null,
                'score_fair' => $plannedPair['score_fair'] ?? null,
                'score_personality_total' => $plannedPair['score_personality_total'] ?? null,
                'score_mbti_total' => $plannedPair['score_mbti_total'] ?? null,
                'score_astro_total' => $plannedPair['score_astro_total'] ?? null,
                'score_overall' => $plannedPair['score_overall'] ?? null,
                'score_bazi' => $plannedPair['score_bazi'] ?? null,
                'score_zodiac' => $plannedPair['score_zodiac'] ?? null,
                'score_constellation' => $plannedPair['score_constellation'] ?? null,
                'score_natal_chart' => $plannedPair['score_natal_chart'] ?? null,
                'match_verdict' => $plannedPair['match_verdict'] ?? null,
                'match_reasons' => $plannedPair['match_reasons'] ?? null,
                'penalty_factors' => $plannedPair['penalty_factors'] ?? null,
                'drop_released' => false,
            ]);
            $pairsCreated++;
            $createdMatchIds[] = (int) $match->id;
        }

        $released = 0;
        if ((bool) $this->option('release-drop')) {
            $released = DatingMatch::query()
                ->where('week_tag', $weekTag)
                ->update(['drop_released' => true]);
        }

        $this->line('week_tag='.$weekTag);
        $this->line('eligible_users='.$users->count());
        $this->line('include_synthetic_users='.($includeSyntheticUsers ? 'true' : 'false'));
        $this->line('pairs_created='.$pairsCreated);
        $this->line('pairs_existing='.$pairsExisting);
        $this->line('released='.$released);
        $this->line('total_match_ids='.count($createdMatchIds));

        return self::SUCCESS;
    }
}
