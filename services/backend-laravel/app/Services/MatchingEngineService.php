<?php

namespace App\Services;

use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserAstroProfile;
use App\Support\EvidenceTagMapper;
use App\Support\ExplanationMetaBuilder;
use Carbon\CarbonImmutable;
use Illuminate\Support\Arr;

class MatchingEngineService
{
    private const IMPORTANCE_WEIGHT = [
        0 => 0.0,
        1 => 0.33,
        2 => 0.66,
        3 => 1.0,
    ];

    private function personalityTestEnabled(): bool
    {
        return (bool) config('features.personality_test_enabled', false);
    }

    /**
     * @param array<int,array{vector:array<string,int>}> $profiles
     * @param array<int,array{created_at:\DateTimeInterface|string|null,updated_at:\DateTimeInterface|string|null}> $usersMeta
     * @return array<int,array<string,mixed>>
     */
    public function buildPairs(array $profiles, array $usersMeta = []): array
    {
        $userIds = array_values(array_map('intval', array_keys($profiles)));
        if (count($userIds) < 2) {
            return [];
        }

        $answerIndex = $this->buildAnswerIndex($userIds);
        $userSignals = $this->loadUserSignals($userIds);
        $recentPairs = $this->recentPairSet($userIds);
        $exposureCounts = $this->recentExposureCounts($userIds);
        $used = [];
        $pairs = [];
        $astro = app(AstroCompatibilityService::class);
        $personality = app(PersonalityCompatibilityService::class);
        $mbti = app(MbtiCompatibilityService::class);
        $personalityEnabled = $this->personalityTestEnabled();
        $contractVersion = (string) config('matching.contract.version', 'v1');

        foreach ($userIds as $uid) {
            if (isset($used[$uid])) {
                continue;
            }

            $bestPeer = null;
            $bestDetail = null;
            foreach ($userIds as $peer) {
                if ($peer === $uid || isset($used[$peer])) {
                    continue;
                }
                if (!$this->passesHardFilters($uid, $peer, $answerIndex, $userSignals, $recentPairs)) {
                    continue;
                }
                $detail = $this->pairScoreDetail(
                    $uid,
                    $peer,
                    $profiles,
                    $answerIndex,
                    $userSignals,
                    $usersMeta,
                    $exposureCounts,
                    $astro,
                    $personality,
                    $mbti,
                    $personalityEnabled
                );
                if ($bestDetail === null || $detail['final'] > $bestDetail['final']) {
                    $bestPeer = $peer;
                    $bestDetail = $detail;
                }
            }

            if ($bestPeer === null || $bestDetail === null) {
                continue;
            }

            $used[$uid] = true;
            $used[$bestPeer] = true;
            $tags = $this->explanationTags($bestDetail);
            $pairs[] = [
                'user_a' => $uid,
                'user_b' => $bestPeer,
                'score' => (int) round($bestDetail['fair_adjusted'] * 100),
                'highlights' => $this->highlights($bestDetail, $tags),
                'explanation_tags' => $tags,
                'score_base' => (int) round($bestDetail['base'] * 100),
                'score_final' => (int) round($bestDetail['final'] * 100),
                'score_fair' => (int) round($bestDetail['fair_adjusted'] * 100),
                'score_personality_total' => (int) ($bestDetail['personality']['score'] ?? 0),
                'score_mbti_total' => (int) ($bestDetail['mbti']['score'] ?? 0),
                'score_astro_total' => (int) ($bestDetail['astro']['total'] ?? 0),
                'score_overall' => (int) round($bestDetail['fair_adjusted'] * 100),
                'score_bazi' => (int) ($bestDetail['astro']['bazi'] ?? 0),
                'score_zodiac' => (int) ($bestDetail['astro']['zodiac'] ?? 0),
                'score_constellation' => (int) ($bestDetail['astro']['constellation'] ?? 0),
                'score_natal_chart' => (int) ($bestDetail['astro']['natal_chart'] ?? 0),
                'score_ziwei' => (int) ($bestDetail['astro']['ziwei'] ?? 0),
                'match_verdict' => (string) ($bestDetail['astro']['verdict'] ?? 'low'),
                'match_reasons' => [
                    'contract_version' => $contractVersion,
                    'generated_at' => now()->toIso8601String(),
                    'summary' => (string) ($bestDetail['astro']['summary'] ?? ''),
                    'match' => (array) ($bestDetail['astro']['reasons_match'] ?? []),
                    'mismatch' => (array) ($bestDetail['astro']['reasons_mismatch'] ?? []),
                    'confidence' => (float) ($bestDetail['overall_confidence'] ?? 0.5),
                    // display_score: user-facing readability
                    'display_score' => (int) round($bestDetail['final'] * 100),
                    // rank_score: matching engine ordering score (fairness-adjusted)
                    'rank_score' => (int) round($bestDetail['fair_adjusted'] * 100),
                    'modules' => (array) ($bestDetail['reason_modules'] ?? []),
                ],
                'penalty_factors' => $bestDetail['penalty_factors'],
            ];
        }

        return $pairs;
    }

    /**
     * @param array<int,array{vector:array<string,int>}> $profiles
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int}>> $answerIndex
     * @param array<int,array{city:string,birthday:?string,mbti:string}> $userSignals
     * @param array<int,array{created_at:\DateTimeInterface|string|null,updated_at:\DateTimeInterface|string|null}> $usersMeta
     * @param array<int,int> $exposureCounts
     */
    private function pairScoreDetail(
        int $a,
        int $b,
        array $profiles,
        array $answerIndex,
        array $userSignals,
        array $usersMeta,
        array $exposureCounts,
        AstroCompatibilityService $astro,
        PersonalityCompatibilityService $personality,
        MbtiCompatibilityService $mbti,
        bool $personalityEnabled
    ): array {
        $profileSimilarity = $this->profileSimilarity(
            (array) ($profiles[$a]['vector'] ?? []),
            (array) ($profiles[$b]['vector'] ?? [])
        );

        $questionAB = $this->questionCompatibilityDirectional(
            $a,
            $b,
            $answerIndex
        );
        $questionBA = $this->questionCompatibilityDirectional(
            $b,
            $a,
            $answerIndex
        );
        $biQuestion = ($questionAB['score'] + $questionBA['score']) / 2.0;

        $interestSimilarity = $this->interestSimilarity($a, $b, $answerIndex);
        $activityA = $this->activityScore($usersMeta[$a]['updated_at'] ?? null);
        $activityB = $this->activityScore($usersMeta[$b]['updated_at'] ?? null);

        $likeAB = (0.30 * $profileSimilarity)
            + (0.20 * $interestSimilarity)
            + (0.35 * $questionAB['score'])
            + (0.15 * $activityB);
        $likeBA = (0.30 * $profileSimilarity)
            + (0.20 * $interestSimilarity)
            + (0.35 * $questionBA['score'])
            + (0.15 * $activityA);

        $reciprocal = max(0.0, min(1.0, $likeAB * $likeBA));

        $freshness = (
            $this->freshnessScore($usersMeta[$a]['created_at'] ?? null)
            + $this->freshnessScore($usersMeta[$b]['created_at'] ?? null)
        ) / 2.0;

        $astroScore = $astro->score([
            'zodiac_animal' => (string) ($userSignals[$a]['zodiac_animal'] ?? ''),
            'public_zodiac_sign' => (string) ($userSignals[$a]['public_zodiac_sign'] ?? ''),
            'private_bazi' => (string) ($userSignals[$a]['private_bazi'] ?? ''),
            'private_natal_chart' => $userSignals[$a]['private_natal_chart'] ?? null,
            'private_ziwei' => $userSignals[$a]['private_ziwei'] ?? null,
            'birthday' => (string) ($userSignals[$a]['birthday'] ?? ''),
            'gender' => (string) ($userSignals[$a]['gender'] ?? ''),
        ], [
            'zodiac_animal' => (string) ($userSignals[$b]['zodiac_animal'] ?? ''),
            'public_zodiac_sign' => (string) ($userSignals[$b]['public_zodiac_sign'] ?? ''),
            'private_bazi' => (string) ($userSignals[$b]['private_bazi'] ?? ''),
            'private_natal_chart' => $userSignals[$b]['private_natal_chart'] ?? null,
            'private_ziwei' => $userSignals[$b]['private_ziwei'] ?? null,
            'birthday' => (string) ($userSignals[$b]['birthday'] ?? ''),
            'gender' => (string) ($userSignals[$b]['gender'] ?? ''),
        ]);
        $personalityScore = $personalityEnabled
            ? $personality->score(
                (array) ($profiles[$a]['vector'] ?? []),
                (array) ($profiles[$b]['vector'] ?? []),
                $profileSimilarity,
                $biQuestion,
                $interestSimilarity,
                $this->categoryCompatibility($a, $b, $answerIndex)
            )
            : [
                'score' => 0,
                'confidence' => 0.0,
                'verdict' => 'disabled',
                'reason_short' => '性格测试已关闭，不再作为排序依据。',
                'reason_detail' => '性格测试模块在 2.5 中已关闭，仅保留历史兼容数据。',
                'risk' => '当前不再使用性格测试进行排序。',
                'risk_detail' => '历史结果仍可读取，但不会参与匹配计算。',
                'evidence_tags' => ['personality_disabled'],
                'evidence' => [],
                'degraded' => true,
                'degrade_reason' => 'personality_disabled',
            ];
        $mbtiScore = [
            'score' => 0,
            'confidence' => 0.0,
            'verdict' => 'disabled',
            'reason_short' => '性格测试已关闭，不再作为排序依据。',
            'reason_detail' => 'MBTI 模块在 2.5 中已关闭，仅保留历史兼容数据。',
            'risk' => '当前不再使用 MBTI 进行排序。',
            'risk_detail' => '历史结果仍可读取，但不会参与匹配计算。',
            'evidence_tags' => ['mbti_disabled'],
            'evidence' => [],
            'degraded' => true,
            'degrade_reason' => 'mbti_disabled',
        ];
        if ($personalityEnabled) {
            $mbtiScore = $mbti->score(
                (string) ($userSignals[$a]['mbti'] ?? ''),
                (string) ($userSignals[$b]['mbti'] ?? '')
            );
        }

        $weights = (array) config('matching.core_weights', []);
        $wPersonality = $personalityEnabled ? (float) ($weights['personality'] ?? 0.50) : 0.0;
        $wMbti = $personalityEnabled ? (float) ($weights['mbti'] ?? 0.15) : 0.0;
        $wAstro = (float) ($weights['astro'] ?? 0.35);
        $coreTotal = (int) round(
            ((int) ($personalityScore['score'] ?? 0)) * $wPersonality
            + ((int) ($mbtiScore['score'] ?? 0)) * $wMbti
            + ((int) ($astroScore['total'] ?? 0)) * $wAstro
        );

        $base = max(0.0, min(1.0, $coreTotal / 100.0));
        $penalty = $this->penaltyFactors($a, $b, $answerIndex, $userSignals);
        $penaltyProduct = array_product(array_values($penalty));
        $final = $base * $penaltyProduct;

        $guards = (array) config('matching.score_guards', []);
        $pScore = (int) ($personalityScore['score'] ?? 0);
        $lowThreshold = (int) ($guards['personality_low_threshold'] ?? 45);
        $lowCap = (int) ($guards['personality_low_cap'] ?? 72);
        $highThreshold = (int) ($guards['personality_high_threshold'] ?? 75);
        $highFloor = (int) ($guards['personality_high_floor'] ?? 40);
        if ($personalityEnabled) {
            if ($pScore < $lowThreshold) {
                $final = min($final, $lowCap / 100.0);
            }
            if ($pScore >= $highThreshold) {
                $final = max($final, $highFloor / 100.0);
            }
        }

        $fairAdjusted = $final * $this->fairnessMultiplier($b, $exposureCounts);
        if ($personalityEnabled) {
            if ($pScore < $lowThreshold) {
                $fairAdjusted = min($fairAdjusted, $lowCap / 100.0);
            }
            if ($pScore >= $highThreshold) {
                $fairAdjusted = max($fairAdjusted, $highFloor / 100.0);
            }
        }

        $reasonModules = $this->buildReasonModules(
            $personalityScore,
            $mbtiScore,
            $astroScore,
            $wPersonality,
            $wMbti,
            $wAstro,
            $personalityEnabled
        );
        $overallConfidence = $this->overallConfidence($reasonModules);

        return [
            'base' => max(0.0, min(1.0, $base)),
            'final' => max(0.0, min(1.0, $final)),
            'fair_adjusted' => max(0.0, min(1.0, $fairAdjusted)),
            'reciprocal' => $reciprocal,
            'bi_question' => $biQuestion,
            'freshness' => $freshness,
            'interest' => $interestSimilarity,
            'activity_avg' => ($activityA + $activityB) / 2.0,
            'penalty_factors' => $penalty,
            'category_scores' => $this->categoryCompatibility($a, $b, $answerIndex),
            'astro' => $astroScore,
            'personality' => $personalityScore,
            'mbti' => $mbtiScore,
            'reason_modules' => $reasonModules,
            'overall_confidence' => $overallConfidence,
        ];
    }

    /**
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int,category:string}>> $answerIndex
     * @param array<string,bool> $recentPairs
     */
    private function passesHardFilters(int $a, int $b, array $answerIndex, array $userSignals, array $recentPairs): bool
    {
        $days = max(0, (int) config('matching.hard_filters.exclude_recent_pair_days', 14));
        if ($days > 0 && isset($recentPairs[$this->pairKey($a, $b)])) {
            return false;
        }

        if ((bool) config('matching.hard_filters.same_city_only', true)) {
            // V1 product rule: city must match.
            $cityA = $this->normalizeCityForMatch((string) ($userSignals[$a]['city'] ?? ''));
            $cityB = $this->normalizeCityForMatch((string) ($userSignals[$b]['city'] ?? ''));
            if ($cityA === '' || $cityB === '' || $cityA !== $cityB) {
                return false;
            }
        }

        if ((bool) config('matching.hard_filters.opposite_gender_only', true)) {
            // V1 product rule: only opposite-sex pairing.
            $genderA = trim((string) ($userSignals[$a]['gender'] ?? ''));
            $genderB = trim((string) ($userSignals[$b]['gender'] ?? ''));
            $allowed = ['male', 'female'];
            if (!in_array($genderA, $allowed, true) || !in_array($genderB, $allowed, true)) {
                return false;
            }
            if ($genderA === $genderB) {
                return false;
            }
        }

        if ((bool) config('matching.hard_filters.reject_casual_vs_marriage', true)) {
            $goalA = $this->goalValue($a, $answerIndex);
            $goalB = $this->goalValue($b, $answerIndex);
            $pair = [$goalA, $goalB];
            sort($pair);
            if ($pair === ['casual', 'marriage']) {
                return false;
            }
        }

        return true;
    }

    /**
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int,category:string}>> $answerIndex
     * @param array<int,array{city:string,birthday:?string,mbti:string}> $userSignals
     * @return array<string,float>
     */
    private function penaltyFactors(int $a, int $b, array $answerIndex, array $userSignals): array
    {
        $cfg = config('matching.soft_penalties', []);
        $signalCfg = (array) config('matching.signal_adjustments', []);
        $category = $this->categoryCompatibility($a, $b, $answerIndex);
        $factors = [];

        $goalA = $this->goalValue($a, $answerIndex);
        $goalB = $this->goalValue($b, $answerIndex);
        if ($goalA !== '' && $goalB !== '' && $goalA !== $goalB) {
            $pair = [$goalA, $goalB];
            sort($pair);
            if ($pair === ['casual', 'long_term'] || $pair === ['long_term', 'marriage']) {
                $factors['relationship_goal_partial_mismatch'] = (float) ($cfg['relationship_goal_partial_mismatch'] ?? 0.70);
            }
        }

        if (($category['lifestyle'] ?? 1.0) < 0.55) {
            $factors['lifestyle_mismatch'] = (float) ($cfg['lifestyle_mismatch'] ?? 0.85);
        }
        if (($category['communication'] ?? 1.0) < 0.55) {
            $factors['communication_mismatch'] = (float) ($cfg['communication_mismatch'] ?? 0.88);
        }
        if ($this->interestSimilarity($a, $b, $answerIndex) < 0.35) {
            $factors['interest_overlap_low'] = (float) ($cfg['interest_overlap_low'] ?? 0.92);
        }

        // Same-city boost to improve local matching chance in pilot stage.
        $cityA = $this->normalizeCityForMatch((string) ($userSignals[$a]['city'] ?? ''));
        $cityB = $this->normalizeCityForMatch((string) ($userSignals[$b]['city'] ?? ''));
        if ($cityA !== '' && $cityB !== '' && $cityA === $cityB) {
            $factors['same_city_boost'] = (float) ($signalCfg['same_city_multiplier'] ?? 1.12);
        }

        // Age-gap soft adjustment based on birthday.
        $birthdayA = $this->toCarbon($userSignals[$a]['birthday'] ?? null);
        $birthdayB = $this->toCarbon($userSignals[$b]['birthday'] ?? null);
        if ($birthdayA && $birthdayB) {
            $ageGapYears = abs($birthdayA->diffInYears($birthdayB));
            foreach ((array) ($signalCfg['age_gap'] ?? []) as $bucket) {
                $max = (int) ($bucket['max'] ?? 999);
                if ($ageGapYears <= $max) {
                    $factors['age_gap_adjustment'] = (float) ($bucket['multiplier'] ?? 1.0);
                    break;
                }
            }
        }

        // MBTI legacy compatibility remains disabled when personality test is closed.
        $mbtiCfg = (array) ($signalCfg['mbti'] ?? []);
        if ($this->personalityTestEnabled() && (bool) ($mbtiCfg['enabled'] ?? true)) {
            $mbtiA = strtoupper((string) ($userSignals[$a]['mbti'] ?? ''));
            $mbtiB = strtoupper((string) ($userSignals[$b]['mbti'] ?? ''));
            if (strlen($mbtiA) === 4 && strlen($mbtiB) === 4) {
                $matches = 0;
                for ($i = 0; $i < 4; $i++) {
                    if ($mbtiA[$i] === $mbtiB[$i]) {
                        $matches++;
                    }
                }
                $perLetter = (float) ($mbtiCfg['per_letter_bonus'] ?? 0.015);
                $maxMultiplier = (float) ($mbtiCfg['max_multiplier'] ?? 1.06);
                $mbtiFactor = 1.0 + ($matches * $perLetter);
                $factors['mbti_letter_match'] = min($maxMultiplier, max(0.90, $mbtiFactor));
            }
        }

        if (empty($factors)) {
            return ['none' => 1.0];
        }
        return $factors;
    }

    /**
     * @param array<int,int> $exposureCounts
     */
    private function fairnessMultiplier(int $candidateId, array $exposureCounts): float
    {
        $exposure = (int) ($exposureCounts[$candidateId] ?? 0);
        foreach ((array) config('matching.fairness.buckets', []) as $bucket) {
            $min = (int) ($bucket['min'] ?? 0);
            if ($exposure >= $min) {
                return (float) ($bucket['multiplier'] ?? 1.0);
            }
        }
        return 1.0;
    }

    /**
     * @param array<string,int> $a
     * @param array<string,int> $b
     */
    private function profileSimilarity(array $a, array $b): float
    {
        $dims = array_unique(array_merge(array_keys($a), array_keys($b)));
        if (count($dims) === 0) {
            return 0.5;
        }
        $sumDiff = 0.0;
        foreach ($dims as $dim) {
            $sumDiff += abs((float) ($a[$dim] ?? 50) - (float) ($b[$dim] ?? 50));
        }
        $avgDiff = $sumDiff / count($dims);
        return max(0.0, min(1.0, 1.0 - ($avgDiff / 100.0)));
    }

    /**
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int}>> $answerIndex
     * @return array{score:float,by_question:array<int,float>}
     */
    private function questionCompatibilityDirectional(int $viewer, int $candidate, array $answerIndex): array
    {
        $viewerAnswers = $answerIndex[$viewer] ?? [];
        $candidateAnswers = $answerIndex[$candidate] ?? [];
        if (empty($viewerAnswers) || empty($candidateAnswers)) {
            return ['score' => 0.0, 'by_question' => []];
        }

        $sum = 0.0;
        $den = 0.0;
        $byQuestion = [];

        foreach ($viewerAnswers as $questionId => $rowA) {
            $rowB = $candidateAnswers[$questionId] ?? null;
            if (!$rowB) {
                continue;
            }
            $weight = self::IMPORTANCE_WEIGHT[$rowA['importance'] ?? 2] ?? 0.66;
            if ($weight <= 0) {
                continue;
            }
            $agreement = $this->agreementScore(
                $rowB['selected'] ?? [],
                $rowA['acceptable'] ?? []
            );
            $sum += $agreement * $weight;
            $den += $weight;
            $byQuestion[$questionId] = $agreement;
        }

        return [
            'score' => $den > 0 ? ($sum / $den) : 0.0,
            'by_question' => $byQuestion,
        ];
    }

    /**
     * @param array<int,string> $selectedByCandidate
     * @param array<int,string> $acceptableByViewer
     */
    private function agreementScore(array $selectedByCandidate, array $acceptableByViewer): float
    {
        $selected = array_values(array_unique(array_filter(array_map('strval', $selectedByCandidate))));
        $acceptable = array_values(array_unique(array_filter(array_map('strval', $acceptableByViewer))));
        if (empty($selected) || empty($acceptable)) {
            return 0.0;
        }

        if (count($selected) === 1) {
            return in_array($selected[0], $acceptable, true) ? 1.0 : 0.0;
        }

        $hit = count(array_intersect($selected, $acceptable));
        return max(0.0, min(1.0, $hit / count($selected)));
    }

    /**
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int,category:string}>> $answerIndex
     * @return array<string,float>
     */
    private function categoryCompatibility(int $a, int $b, array $answerIndex): array
    {
        $result = [];
        $qa = $answerIndex[$a] ?? [];
        $qb = $answerIndex[$b] ?? [];
        $byCat = [];

        foreach ($qa as $qid => $rowA) {
            $rowB = $qb[$qid] ?? null;
            if (!$rowB) {
                continue;
            }
            $cat = (string) ($rowA['category'] ?? 'unknown');
            $ab = $this->agreementScore($rowB['selected'] ?? [], $rowA['acceptable'] ?? []);
            $ba = $this->agreementScore($rowA['selected'] ?? [], $rowB['acceptable'] ?? []);
            $bi = ($ab + $ba) / 2.0;
            $wA = self::IMPORTANCE_WEIGHT[$rowA['importance'] ?? 2] ?? 0.66;
            $wB = self::IMPORTANCE_WEIGHT[$rowB['importance'] ?? 2] ?? 0.66;
            $w = ($wA + $wB) / 2.0;

            if (!isset($byCat[$cat])) {
                $byCat[$cat] = ['sum' => 0.0, 'den' => 0.0];
            }
            $byCat[$cat]['sum'] += $bi * $w;
            $byCat[$cat]['den'] += $w;
        }

        foreach ($byCat as $cat => $v) {
            $result[$cat] = $v['den'] > 0 ? ($v['sum'] / $v['den']) : 0.0;
        }

        return $result;
    }

    /**
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int,category:string}>> $answerIndex
     */
    private function interestSimilarity(int $a, int $b, array $answerIndex): float
    {
        $aVals = [];
        foreach (($answerIndex[$a] ?? []) as $row) {
            if (($row['category'] ?? '') !== 'interests') {
                continue;
            }
            $aVals = array_merge($aVals, $row['selected'] ?? []);
        }

        $bVals = [];
        foreach (($answerIndex[$b] ?? []) as $row) {
            if (($row['category'] ?? '') !== 'interests') {
                continue;
            }
            $bVals = array_merge($bVals, $row['selected'] ?? []);
        }

        $aVals = array_values(array_unique(array_filter($aVals)));
        $bVals = array_values(array_unique(array_filter($bVals)));
        if (empty($aVals) || empty($bVals)) {
            return 0.5;
        }

        $inter = count(array_intersect($aVals, $bVals));
        $union = count(array_unique(array_merge($aVals, $bVals)));
        return $union > 0 ? ($inter / $union) : 0.0;
    }

    private function activityScore($updatedAt): float
    {
        $dt = $this->toCarbon($updatedAt);
        if (!$dt) {
            return 0.5;
        }
        $days = max(0, now()->diffInDays($dt));
        return (float) exp(-$days / 14.0);
    }

    private function freshnessScore($createdAt): float
    {
        $dt = $this->toCarbon($createdAt);
        if (!$dt) {
            return 0.0;
        }
        $days = max(0, now()->diffInDays($dt));
        return (float) exp(-$days / 7.0);
    }

    private function toCarbon($value): ?CarbonImmutable
    {
        if ($value instanceof CarbonImmutable) {
            return $value;
        }
        if ($value instanceof \DateTimeInterface) {
            return CarbonImmutable::instance(\DateTime::createFromInterface($value));
        }
        if (is_string($value) && $value !== '') {
            return CarbonImmutable::parse($value);
        }
        return null;
    }

    private function highlights(array $detail, array $tags): string
    {
        if (!empty($detail['reason_modules']) && is_array($detail['reason_modules'])) {
            $first = Arr::first($detail['reason_modules']);
            if (is_array($first)) {
                $text = (string) data_get($first, 'highlights.0.text', '');
                if ($text !== '') {
                    return $text;
                }
            }
        }
        if (!empty($detail['astro']['verdict'])) {
            $v = (string) $detail['astro']['verdict'];
            $head = $v === 'high' ? '高匹配' : ($v === 'medium' ? '中匹配' : '低匹配');
            $reason = (string) (($detail['astro']['reasons_match'][0] ?? '') ?: ($detail['astro']['reasons_mismatch'][0] ?? ''));
            return trim("{$head}：{$reason}", '：');
        }
        if (empty($tags)) {
            return '画像匹配：互惠意向较高';
        }
        return '画像匹配：'.implode('；', $tags);
    }

    /**
     * @param array{category_scores:array<string,float>,interest:float,activity_avg:float,freshness:float} $detail
     * @return array<int,string>
     */
    private function explanationTags(array $detail): array
    {
        if (!empty($detail['reason_modules']) && is_array($detail['reason_modules'])) {
            $tags = [];
            foreach ($detail['reason_modules'] as $module) {
                $t = (string) data_get($module, 'highlights.0.text', '');
                if ($t !== '') {
                    $tags[] = $t;
                }
            }
            $tags = array_slice(array_values(array_unique($tags)), 0, 3);
            if (!empty($tags)) {
                return $tags;
            }
        }

        if (!empty($detail['astro'])) {
            $astro = (array) $detail['astro'];
            $list = array_values(array_unique(array_filter(array_merge(
                array_slice((array) ($astro['reasons_match'] ?? []), 0, 2),
                array_slice((array) ($astro['reasons_mismatch'] ?? []), 0, 1)
            ))));
            if (!empty($list)) {
                return array_slice($list, 0, 3);
            }
        }

        $cat = $detail['category_scores'] ?? [];
        $tags = [];

        if (($cat['relationship_goals'] ?? 0) >= 0.75) {
            $tags[] = '你们对关系目标很一致';
        }
        if (($cat['values'] ?? 0) >= 0.8) {
            $tags[] = '你们的价值观比较契合';
        }
        if (($cat['communication'] ?? 0) >= 0.75) {
            $tags[] = '你们的沟通方式比较合拍';
        }
        if (($cat['lifestyle'] ?? 0) >= 0.75) {
            $tags[] = '你们的生活方式比较接近';
        }
        if (($cat['family'] ?? 0) >= 0.8) {
            $tags[] = '你们对家庭议题的看法接近';
        }
        if (($cat['social_energy'] ?? 0) >= 0.75) {
            $tags[] = '你们的社交节奏更容易平衡';
        }
        if (($detail['interest'] ?? 0) >= 0.6) {
            $tags[] = '你们有不少共同兴趣';
        }
        if (($detail['activity_avg'] ?? 0) >= 0.8) {
            $tags[] = '双方近期都比较活跃';
        }
        if (($detail['freshness'] ?? 0) >= 0.8) {
            $tags[] = '你们都在近期加入，节奏相近';
        }

        return array_slice(array_values(array_unique($tags)), 0, 3);
    }

    /**
     * @param array<string,mixed> $personality
     * @param array<string,mixed> $mbti
     * @param array<string,mixed> $astro
     * @return array<int,array<string,mixed>>
     */
    private function buildReasonModules(
        array $personality,
        array $mbti,
        array $astro,
        float $wPersonality,
        float $wMbti,
        float $wAstro,
        bool $personalityEnabled
    ): array {
        $algo = (array) config('matching.algo_versions', []);
        $modules = [];

        if ($personalityEnabled && $wPersonality > 0.0) {
            $modules[] = [
                'key' => 'personality',
                'label' => '人格匹配',
                'layer' => 'process',
                'algo_version' => (string) ($algo['personality'] ?? 'p1'),
                'score' => (int) ($personality['score'] ?? 0),
                'weight' => round($wPersonality, 4),
                'confidence' => (float) ($personality['confidence'] ?? 0.7),
                'verdict' => (string) ($personality['verdict'] ?? 'medium'),
                'reason_short' => (string) (($personality['reason_short'] ?? '') ?: ($personality['highlight'] ?? '')),
                'reason_detail' => (string) ($personality['reason_detail'] ?? ''),
                'risk_short' => (string) ($personality['risk'] ?? ''),
                'risk_detail' => (string) ($personality['risk_detail'] ?? ''),
                'evidence_tags' => (array) ($personality['evidence_tags'] ?? []),
                'evidence' => (array) ($personality['evidence'] ?? []),
                'highlights' => [[
                    'text' => (string) (($personality['reason_short'] ?? '') ?: ($personality['highlight'] ?? '')),
                    'evidence_tags' => (array) ($personality['evidence_tags'] ?? []),
                    'evidence' => (array) ($personality['evidence'] ?? []),
                ], [
                    'text' => (string) ($personality['reason_detail'] ?? ''),
                    'evidence_tags' => (array) ($personality['evidence_tags'] ?? []),
                    'evidence' => (array) ($personality['evidence'] ?? []),
                ]],
                'risks' => [[
                    'text' => (string) ($personality['risk'] ?? ''),
                    'evidence_tags' => (array) ($personality['evidence_tags'] ?? []),
                    'evidence' => (array) ($personality['evidence'] ?? []),
                ], [
                    'text' => (string) ($personality['risk_detail'] ?? ''),
                    'evidence_tags' => (array) ($personality['evidence_tags'] ?? []),
                    'evidence' => (array) ($personality['evidence'] ?? []),
                ]],
                'degraded' => (bool) ($personality['degraded'] ?? false),
                'degrade_reason' => (string) ($personality['degrade_reason'] ?? ''),
            ];
        }

        if ($personalityEnabled && $wMbti > 0.0) {
            $modules[] = [
                'key' => 'mbti',
                'label' => 'MBTI 匹配',
                'layer' => 'process',
                'algo_version' => (string) ($algo['mbti'] ?? 'p1'),
                'score' => (int) ($mbti['score'] ?? 0),
                'weight' => round($wMbti, 4),
                'confidence' => (float) ($mbti['confidence'] ?? 0.55),
                'verdict' => (string) ($mbti['verdict'] ?? 'medium'),
                'reason_short' => (string) (($mbti['reason_short'] ?? '') ?: ($mbti['highlight'] ?? '')),
                'reason_detail' => (string) ($mbti['reason_detail'] ?? ''),
                'risk_short' => (string) ($mbti['risk'] ?? ''),
                'risk_detail' => (string) ($mbti['risk_detail'] ?? ''),
                'evidence_tags' => (array) ($mbti['evidence_tags'] ?? []),
                'evidence' => (array) ($mbti['evidence'] ?? []),
                'highlights' => [[
                    'text' => (string) (($mbti['reason_short'] ?? '') ?: ($mbti['highlight'] ?? '')),
                    'evidence_tags' => (array) ($mbti['evidence_tags'] ?? []),
                    'evidence' => (array) ($mbti['evidence'] ?? []),
                ], [
                    'text' => (string) ($mbti['reason_detail'] ?? ''),
                    'evidence_tags' => (array) ($mbti['evidence_tags'] ?? []),
                    'evidence' => (array) ($mbti['evidence'] ?? []),
                ]],
                'risks' => [[
                    'text' => (string) ($mbti['risk'] ?? ''),
                    'evidence_tags' => (array) ($mbti['evidence_tags'] ?? []),
                    'evidence' => (array) ($mbti['evidence'] ?? []),
                ], [
                    'text' => (string) ($mbti['risk_detail'] ?? ''),
                    'evidence_tags' => (array) ($mbti['evidence_tags'] ?? []),
                    'evidence' => (array) ($mbti['evidence'] ?? []),
                ]],
                'degraded' => (bool) ($mbti['degraded'] ?? false),
                'degrade_reason' => (string) ($mbti['degrade_reason'] ?? ''),
            ];
        }

        $astroWeightMap = (array) config('match_rules.weights', []);
        $astroKeys = ['bazi', 'zodiac', 'constellation', 'natal_chart', 'ziwei', 'pair_chart'];
        $sumAstroWeight = 0.0;
        foreach ($astroKeys as $k) {
            $sumAstroWeight += (float) ($astroWeightMap[$k] ?? 0.0);
        }
        $sumAstroWeight = $sumAstroWeight > 0.0 ? $sumAstroWeight : 1.0;
        $astroDetail = (array) ($astro['module_details'] ?? []);
        $astroLabels = [
            'bazi' => '八字匹配',
            'zodiac' => '属相匹配',
            'constellation' => '星座匹配',
            'natal_chart' => '星盘匹配',
            'ziwei' => '紫微斗数',
            'pair_chart' => '男女合盘',
        ];
        foreach ($astroLabels as $key => $label) {
            $row = (array) ($astroDetail[$key] ?? []);
            if (empty($row) && !array_key_exists($key, $astroDetail)) {
                continue;
            }
            $localAstroWeight = round($wAstro * (((float) ($astroWeightMap[$key] ?? 0.0)) / $sumAstroWeight), 4);
            $modules[] = [
                'key' => $key,
                'label' => $label,
                'layer' => $key === 'bazi' ? 'result' : (($key === 'zodiac' || $key === 'pair_chart' || $key === 'ziwei') ? 'bridge' : 'process'),
                'algo_version' => (string) ($algo[$key] ?? 'p1'),
                'score' => (int) ($row['score'] ?? 0),
                'weight' => $localAstroWeight,
                'confidence' => (float) ($row['confidence'] ?? 0.6),
                'verdict' => $this->scoreVerdict((int) ($row['score'] ?? 0)),
                'reason_short' => (string) (($row['reason_short'] ?? '') ?: ($row['match'] ?? '')),
                'reason_detail' => (string) ($row['reason_detail'] ?? ''),
                'risk_short' => (string) ($row['mismatch'] ?? ''),
                'risk_detail' => (string) ($row['risk_detail'] ?? ''),
                'evidence_tags' => (array) ($row['evidence_tags'] ?? []),
                'evidence' => (array) ($row['evidence'] ?? []),
                'highlights' => [[
                    'text' => (string) (($row['reason_short'] ?? '') ?: ($row['match'] ?? '')),
                    'evidence_tags' => (array) ($row['evidence_tags'] ?? []),
                    'evidence' => (array) ($row['evidence'] ?? []),
                ], [
                    'text' => (string) ($row['reason_detail'] ?? ''),
                    'evidence_tags' => (array) ($row['evidence_tags'] ?? []),
                    'evidence' => (array) ($row['evidence'] ?? []),
                ]],
                'risks' => [[
                    'text' => (string) ($row['mismatch'] ?? ''),
                    'evidence_tags' => (array) ($row['evidence_tags'] ?? []),
                    'evidence' => (array) ($row['evidence'] ?? []),
                ], [
                    'text' => (string) ($row['risk_detail'] ?? ''),
                    'evidence_tags' => (array) ($row['evidence_tags'] ?? []),
                    'evidence' => (array) ($row['evidence'] ?? []),
                ]],
                'degraded' => (bool) ($row['degraded'] ?? false),
                'degrade_reason' => (string) ($row['degrade_reason'] ?? ''),
            ];
        }

        // Remove empty rows to reduce payload noise.
        /** @var ExplanationMetaBuilder $metaBuilder */
        $metaBuilder = app(ExplanationMetaBuilder::class);
        /** @var EvidenceTagMapper $tagMapper */
        $tagMapper = app(EvidenceTagMapper::class);

        foreach ($modules as &$m) {
            $m['highlights'] = array_values(array_filter((array) ($m['highlights'] ?? []), fn ($x) => trim((string) ($x['text'] ?? '')) !== ''));
            $m['risks'] = array_values(array_filter((array) ($m['risks'] ?? []), fn ($x) => trim((string) ($x['text'] ?? '')) !== ''));

            if (trim((string) ($m['reason_short'] ?? '')) === '') {
                $m['reason_short'] = (string) data_get($m, 'highlights.0.text', '');
            }
            if (trim((string) ($m['reason_detail'] ?? '')) === '') {
                $m['reason_detail'] = (string) data_get($m, 'highlights.1.text', '');
            }
            if (trim((string) ($m['risk_short'] ?? '')) === '') {
                $m['risk_short'] = (string) data_get($m, 'risks.0.text', '');
            }
            if (trim((string) ($m['risk_detail'] ?? '')) === '') {
                $m['risk_detail'] = (string) data_get($m, 'risks.1.text', '');
            }

            $inlineTags = array_merge(
                (array) ($m['evidence_tags'] ?? []),
                (array) data_get($m, 'highlights.0.evidence_tags', []),
                (array) data_get($m, 'highlights.1.evidence_tags', []),
                (array) data_get($m, 'risks.0.evidence_tags', []),
                (array) data_get($m, 'risks.1.evidence_tags', [])
            );
            $m['evidence_tags'] = array_values(array_unique(array_filter(array_map('strval', $inlineTags))));
            if (!is_array($m['evidence'] ?? null) || empty($m['evidence'])) {
                $m['evidence'] = (array) (
                    data_get($m, 'highlights.0.evidence', [])
                    ?: data_get($m, 'highlights.1.evidence', [])
                    ?: data_get($m, 'risks.0.evidence', [])
                    ?: []
                );
            }

            $m = $this->applyConfidenceNarrativePolicy($m);

            $meta = $metaBuilder->build($m);
            $m['engine_source'] = (string) ($meta['engine_source'] ?? 'unknown');
            $m['engine_mode'] = (string) ($meta['engine_mode'] ?? 'legacy');
            $m['data_quality'] = (string) ($meta['data_quality'] ?? 'partial_unknown');
            $m['precision_level'] = (string) ($meta['precision_level'] ?? 'estimated');
            $m['confidence_tier'] = (string) ($meta['confidence_tier'] ?? 'low');
            $m['confidence_reason'] = (array) ($meta['confidence_reason'] ?? []);
            $m['display_guard'] = (array) ($meta['display_guard'] ?? []);

            $m['display_tags'] = $tagMapper->toDisplayLabels((array) ($m['evidence_tags'] ?? []));
        }
        unset($m);

        return $modules;
    }

    /**
     * @param array<string,mixed> $module
     * @return array<string,mixed>
     */
    private function applyConfidenceNarrativePolicy(array $module): array
    {
        $cfg = (array) config('confidence_policy.narrative', []);
        $low = (float) ($cfg['low_confidence_threshold'] ?? 0.55);
        $medium = (float) ($cfg['medium_confidence_threshold'] ?? 0.70);
        $lowSuffix = (string) ($cfg['low_confidence_suffix'] ?? '（当前证据偏弱，建议仅作参考）');
        $degradedSuffix = (string) ($cfg['degraded_suffix'] ?? '（存在降级估算，建议补全出生信息后再判断）');

        $confidence = (float) ($module['confidence'] ?? 0.5);
        $degraded = (bool) ($module['degraded'] ?? false);
        $verdict = strtolower(trim((string) ($module['verdict'] ?? 'medium')));

        $evidenceTags = array_values(array_unique(array_filter(array_map(
            'strval',
            (array) ($module['evidence_tags'] ?? [])
        ))));

        if ($degraded) {
            if ($verdict === 'strong') {
                $module['verdict'] = 'medium';
            }
            $module['reason_short'] = $this->appendOnce((string) ($module['reason_short'] ?? ''), $degradedSuffix);
            $module['reason_detail'] = $this->appendOnce((string) ($module['reason_detail'] ?? ''), $degradedSuffix);
            if (trim((string) ($module['risk_detail'] ?? '')) === '') {
                $module['risk_detail'] = $degradedSuffix;
            }
            $evidenceTags[] = 'degraded_estimation';
        } elseif ($confidence < $low) {
            $module['verdict'] = 'weak';
            $module['reason_short'] = $this->appendOnce((string) ($module['reason_short'] ?? ''), $lowSuffix);
            $module['reason_detail'] = $this->appendOnce((string) ($module['reason_detail'] ?? ''), $lowSuffix);
            if (trim((string) ($module['risk_detail'] ?? '')) === '') {
                $module['risk_detail'] = '当前证据强度较低，建议结合真实互动结果再判断。';
            }
            $evidenceTags[] = 'confidence_low';
        } elseif ($confidence < $medium && $verdict === 'strong') {
            $module['verdict'] = 'medium';
            $module['reason_short'] = $this->appendOnce((string) ($module['reason_short'] ?? ''), '（当前为中等置信）');
            $evidenceTags[] = 'confidence_medium';
        }

        $module['evidence_tags'] = array_values(array_unique($evidenceTags));
        return $module;
    }

    private function appendOnce(string $base, string $suffix): string
    {
        $base = trim($base);
        $suffix = trim($suffix);
        if ($suffix === '') {
            return $base;
        }
        if ($base === '') {
            return $suffix;
        }
        if (str_contains($base, $suffix)) {
            return $base;
        }
        return $base.$suffix;
    }

    /**
     * @param array<int,array<string,mixed>> $modules
     */
    private function overallConfidence(array $modules): float
    {
        if (empty($modules)) {
            return 0.5;
        }
        $sum = 0.0;
        $ws = 0.0;
        foreach ($modules as $m) {
            $w = (float) ($m['weight'] ?? 0.0);
            $c = (float) ($m['confidence'] ?? 0.5);
            if ($w <= 0.0) {
                continue;
            }
            $sum += $w * $c;
            $ws += $w;
        }
        if ($ws <= 0.0) {
            return 0.5;
        }
        return round(max(0.0, min(1.0, $sum / $ws)), 2);
    }

    private function scoreVerdict(int $score): string
    {
        if ($score >= 80) {
            return 'strong';
        }
        if ($score >= 60) {
            return 'medium';
        }
        return 'weak';
    }

    /**
     * @param array<int> $userIds
     * @return array<string,bool>
     */
    private function recentPairSet(array $userIds): array
    {
        $days = max(0, (int) config('matching.hard_filters.exclude_recent_pair_days', 14));
        if ($days <= 0) {
            return [];
        }
        $since = now()->subDays($days);
        $rows = DatingMatch::query()
            ->where('created_at', '>=', $since)
            ->where(function ($q) use ($userIds) {
                $q->whereIn('user_a', $userIds)->orWhereIn('user_b', $userIds);
            })
            ->get(['user_a', 'user_b']);
        $set = [];
        foreach ($rows as $r) {
            $set[$this->pairKey((int) $r->user_a, (int) $r->user_b)] = true;
        }
        return $set;
    }

    /**
     * @param array<int> $userIds
     * @return array<int,int>
     */
    private function recentExposureCounts(array $userIds): array
    {
        $since = now()->subDays(7);
        $rows = DatingMatch::query()
            ->where('created_at', '>=', $since)
            ->where(function ($q) use ($userIds) {
                $q->whereIn('user_a', $userIds)->orWhereIn('user_b', $userIds);
            })
            ->get(['user_a', 'user_b']);
        $count = array_fill_keys($userIds, 0);
        foreach ($rows as $r) {
            $a = (int) $r->user_a;
            $b = (int) $r->user_b;
            if (isset($count[$a])) {
                $count[$a]++;
            }
            if (isset($count[$b])) {
                $count[$b]++;
            }
        }
        return $count;
    }

    private function pairKey(int $a, int $b): string
    {
        return $a < $b ? "{$a}:{$b}" : "{$b}:{$a}";
    }

    private function normalizeCityForMatch(string $city): string
    {
        $c = trim($city);
        if ($c === '') {
            return '';
        }
        // Normalize common Chinese admin suffixes for robust city-equality matching.
        $c = preg_replace('/(省|市|自治区|自治州|地区|盟|区|县)$/u', '', $c) ?: $c;
        return trim($c);
    }

    /**
     * @param array<int> $userIds
     * @return array<int,array{city:string,birthday:?string,mbti:string,gender:string,zodiac_animal:string,public_zodiac_sign:string,private_bazi:string,private_natal_chart:mixed,private_ziwei:mixed}>
     */
    private function loadUserSignals(array $userIds): array
    {
        if (empty($userIds)) {
            return [];
        }

        /** @var ChineseZodiacService $zodiacService */
        $zodiacService = app(ChineseZodiacService::class);

        $rows = User::query()
            ->whereIn('id', $userIds)
            ->get(['id', 'city', 'birthday', 'public_mbti', 'gender', 'zodiac_animal', 'public_zodiac_sign', 'private_bazi', 'private_natal_chart', 'private_ziwei']);
        $astroRows = UserAstroProfile::query()
            ->whereIn('user_id', $userIds)
            ->get([
                'user_id',
                'sun_sign',
                'moon_sign',
                'asc_sign',
                'bazi',
                'true_solar_time',
                'da_yun',
                'liu_nian',
                'wu_xing',
                'notes',
                'computed_at',
            ])
            ->keyBy('user_id');

        $signals = [];
        foreach ($rows as $row) {
            $astro = $astroRows->get((int) $row->id);
            $canonicalSun = trim((string) ($astro?->sun_sign ?? ''));
            $canonicalBazi = trim((string) ($astro?->bazi ?? ''));
            $canonicalChart = $astro ? [
                'moon_sign' => $astro->moon_sign,
                'asc_sign' => $astro->asc_sign,
                'true_solar_time' => $astro->true_solar_time,
                'da_yun' => $astro->da_yun ?? [],
                'liu_nian' => $astro->liu_nian ?? [],
                'wu_xing' => $astro->wu_xing ?? [],
                'notes' => $astro->notes ?? [],
                'computed_at' => optional($astro->computed_at)->toIso8601String(),
            ] : null;

            $birthday = $row->birthday ? (string) $row->birthday : null;
            $resolvedZodiac = $zodiacService->fromPreferredSources(
                $canonicalBazi !== '' ? $canonicalBazi : trim((string) ($row->private_bazi ?? '')),
                $birthday
            );

            $signals[(int) $row->id] = [
                'city' => trim((string) ($row->city ?? '')),
                'birthday' => $birthday,
                'mbti' => trim((string) ($row->public_mbti ?? '')),
                'gender' => trim((string) ($row->gender ?? '')),
                'zodiac_animal' => trim((string) ($resolvedZodiac ?? $row->zodiac_animal ?? '')),
                // Canonical source: user_astro_profiles. Fallback: users mirror fields.
                'public_zodiac_sign' => $canonicalSun !== '' ? $canonicalSun : trim((string) ($row->public_zodiac_sign ?? '')),
                'private_bazi' => $canonicalBazi !== '' ? $canonicalBazi : trim((string) ($row->private_bazi ?? '')),
                'private_natal_chart' => $canonicalChart ?? $row->private_natal_chart,
                'private_ziwei' => $astro?->ziwei ?? $row->private_ziwei,
            ];
        }

        return $signals;
    }

    /**
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int,category:string}>> $answerIndex
     */
    private function goalValue(int $uid, array $answerIndex): string
    {
        foreach (($answerIndex[$uid] ?? []) as $row) {
            if (($row['category'] ?? '') === 'relationship_goals') {
                return (string) (($row['selected'][0] ?? '') ?: '');
            }
        }
        return '';
    }

    /**
     * @param array<int> $userIds
     * @return array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int,category:string}>>
     */
    private function buildAnswerIndex(array $userIds): array
    {
        $questionCategories = QuestionnaireQuestion::query()
            ->whereIn('id', function ($q) use ($userIds) {
                $q->select('questionnaire_question_id')
                    ->from('questionnaire_answers')
                    ->whereIn('user_id', $userIds);
            })
            ->pluck('category', 'id')
            ->map(fn ($v) => (string) ($v ?? 'unknown'))
            ->all();

        $rows = QuestionnaireAnswer::query()
            ->whereIn('user_id', $userIds)
            ->get([
                'user_id',
                'questionnaire_question_id',
                'answer_payload',
                'selected_answer_json',
                'acceptable_answers_json',
                'importance',
            ]);

        $index = [];
        foreach ($rows as $row) {
            $selected = $row->selected_answer_json;
            if (!is_array($selected) || count($selected) === 0) {
                $value = (string) data_get($row->answer_payload, 'value', '');
                $selected = $value !== '' ? [$value] : [];
            }
            $selected = array_values(array_unique(array_filter(array_map('strval', $selected))));
            if (count($selected) === 0) {
                continue;
            }

            $acceptable = $row->acceptable_answers_json;
            if (!is_array($acceptable) || count($acceptable) === 0) {
                $acceptable = data_get($row->answer_payload, 'acceptable_answers', []);
            }
            if (!is_array($acceptable) || count($acceptable) === 0) {
                $acceptable = $selected;
            }
            $acceptable = array_values(array_unique(array_filter(array_map('strval', $acceptable))));

            $importance = $row->importance;
            if (!is_int($importance)) {
                $importance = (int) data_get($row->answer_payload, 'importance', 2);
            }
            $importance = max(0, min(3, $importance));

            $uid = (int) $row->user_id;
            $qid = (int) $row->questionnaire_question_id;
            $index[$uid][$qid] = [
                'selected' => $selected,
                'acceptable' => $acceptable,
                'importance' => $importance,
                'category' => $questionCategories[$qid] ?? 'unknown',
            ];
        }

        return $index;
    }
}
