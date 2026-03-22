<?php

namespace App\Services;

use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use Carbon\CarbonImmutable;

class MatchingEngineService
{
    private const IMPORTANCE_WEIGHT = [
        0 => 0.0,
        1 => 0.33,
        2 => 0.66,
        3 => 1.0,
    ];

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
        $recentPairs = $this->recentPairSet($userIds);
        $exposureCounts = $this->recentExposureCounts($userIds);
        $used = [];
        $pairs = [];

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
                if (!$this->passesHardFilters($uid, $peer, $answerIndex, $recentPairs)) {
                    continue;
                }
                $detail = $this->pairScoreDetail(
                    $uid,
                    $peer,
                    $profiles,
                    $answerIndex,
                    $usersMeta,
                    $exposureCounts
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
                'penalty_factors' => $bestDetail['penalty_factors'],
            ];
        }

        return $pairs;
    }

    /**
     * @param array<int,array{vector:array<string,int>}> $profiles
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int}>> $answerIndex
     * @param array<int,array{created_at:\DateTimeInterface|string|null,updated_at:\DateTimeInterface|string|null}> $usersMeta
     * @param array<int,int> $exposureCounts
     */
    private function pairScoreDetail(
        int $a,
        int $b,
        array $profiles,
        array $answerIndex,
        array $usersMeta,
        array $exposureCounts
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

        $base = (0.70 * $reciprocal) + (0.20 * $biQuestion) + (0.10 * $freshness);
        $penalty = $this->penaltyFactors($a, $b, $answerIndex);
        $penaltyProduct = array_product(array_values($penalty));
        $final = $base * $penaltyProduct;
        $fairAdjusted = $final * $this->fairnessMultiplier($b, $exposureCounts);

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
        ];
    }

    /**
     * @param array<int,array<int,array{selected:array<int,string>,acceptable:array<int,string>,importance:int,category:string}>> $answerIndex
     * @param array<string,bool> $recentPairs
     */
    private function passesHardFilters(int $a, int $b, array $answerIndex, array $recentPairs): bool
    {
        $days = max(0, (int) config('matching.hard_filters.exclude_recent_pair_days', 14));
        if ($days > 0 && isset($recentPairs[$this->pairKey($a, $b)])) {
            return false;
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
     * @return array<string,float>
     */
    private function penaltyFactors(int $a, int $b, array $answerIndex): array
    {
        $cfg = config('matching.soft_penalties', []);
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
