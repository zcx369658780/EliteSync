<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function banner(): JsonResponse
    {
        return response()->json([
            'data' => config('home_content.banner', []),
        ]);
    }

    public function shortcuts(): JsonResponse
    {
        return response()->json([
            'data' => config('home_content.shortcuts', []),
        ]);
    }

    public function feed(Request $request): JsonResponse
    {
        $tab = trim((string) $request->query('tab', 'recommend'));
        $scene = trim((string) $request->query('scene', 'home'));
        $city = trim((string) $request->query('city', (string) optional($request->user())->city));
        $tag = trim((string) $request->query('tag', ''));
        $boostTag = trim((string) $request->query('boost_tag', ''));
        $boostTagSecondary = trim((string) $request->query('boost_tag_secondary', ''));
        $ranker = trim((string) $request->query('ranker', 'auto'));

        return $this->paginateItems(
            scene: $scene === 'discover' ? 'discover' : 'home',
            tab: $tab,
            cursor: (string) $request->query('cursor', ''),
            limit: (int) $request->query('limit', 12),
            city: $city,
            tag: $tag,
            boostTag: $boostTag,
            boostTagSecondary: $boostTagSecondary,
            ranker: $ranker
        );
    }

    public function discoverFeed(Request $request): JsonResponse
    {
        $tab = trim((string) $request->query('tab', 'hot'));
        $city = trim((string) $request->query('city', (string) optional($request->user())->city));
        $tag = trim((string) $request->query('tag', ''));
        $boostTag = trim((string) $request->query('boost_tag', ''));
        $boostTagSecondary = trim((string) $request->query('boost_tag_secondary', ''));
        $ranker = trim((string) $request->query('ranker', 'auto'));

        return $this->paginateItems(
            scene: 'discover',
            tab: $tab,
            cursor: (string) $request->query('cursor', ''),
            limit: (int) $request->query('limit', 12),
            city: $city,
            tag: $tag,
            boostTag: $boostTag,
            boostTagSecondary: $boostTagSecondary,
            ranker: $ranker
        );
    }

    public function content(string $contentId): JsonResponse
    {
        $all = collect(config('home_content.items', []))
            ->map(fn ($item) => $this->shapeFeedItem((array) $item))
            ->keyBy('id');

        $found = $all->get($contentId);
        if ($found !== null) {
            return response()->json(['data' => $found]);
        }

        return response()->json([
            'data' => [
                'id' => $contentId,
                'title' => '内容详情',
                'summary' => '该内容正在完善中，稍后将展示完整正文与互动信息。',
                'author' => '系统',
                'likes' => 0,
                'tags' => ['关系研究'],
                'media' => [],
                'body' => '内容暂未发布。',
            ],
        ]);
    }

    private function paginateItems(
        string $scene,
        string $tab,
        string $cursor,
        int $limit,
        string $city = '',
        string $tag = '',
        string $boostTag = '',
        string $boostTagSecondary = '',
        string $ranker = 'auto'
    ): JsonResponse
    {
        $safeLimit = max(1, min($limit, 30));
        $start = max(0, (int) $cursor);
        $city = trim($city);
        $tag = trim($tag);
        $rankerMode = $this->resolveRankerMode($ranker);

        $baseItems = collect(config('home_content.items', []))
            ->map(fn ($item) => (array) $item)
            ->filter(function (array $item) use ($scene, $tab, $tag) {
                $itemScene = (string) ($item['scene'] ?? 'home');
                if ($itemScene !== $scene) {
                    return false;
                }
                $tabs = collect($item['tabs'] ?? [])->map(fn ($v) => (string) $v)->all();
                if (empty($tabs)) {
                    return true;
                }

                // home: recommend/nearby/topic/event/inspire
                // discover: hot/local/event/topic/live
                $tabMatched = in_array($tab, $tabs, true) || in_array('all', $tabs, true);
                if (!$tabMatched) {
                    return false;
                }
                if ($tag === '') {
                    return true;
                }
                $tags = collect($item['tags'] ?? [])
                    ->map(fn ($v) => trim((string) $v))
                    ->filter(fn ($v) => $v !== '')
                    ->all();
                return in_array($tag, $tags, true);
            })
            ->values();

        $rankedBase = $rankerMode === 'weighted'
            ? $baseItems
                ->values()
                ->map(function (array $item, int $idx) use ($scene, $tab, $city, $tag, $boostTag, $boostTagSecondary) {
                    $item['_rank_score'] = $this->relevanceScore($item, $scene, $tab, $city, $tag, $boostTag, $boostTagSecondary);
                    $item['_rank_index'] = $idx;
                    return $item;
                })
                ->sortBy([
                    ['_rank_score', 'desc'],
                    ['_rank_index', 'asc'],
                ])
                ->values()
                ->map(function (array $item) {
                    unset($item['_rank_score'], $item['_rank_index']);
                    return $item;
                })
                ->values()
            : $baseItems;

        $items = $rankedBase;
        $cityMatchedCount = 0;
        if ($city !== '') {
            $cityMatched = $rankedBase
                ->filter(fn (array $item) => $this->cityMatched((string) ($item['city'] ?? 'all'), $city))
                ->values();
            $cityMatchedCount = $cityMatched->count();
            if ($cityMatched->isNotEmpty()) {
                $otherItems = $rankedBase
                    ->reject(fn (array $item) => $this->cityMatched((string) ($item['city'] ?? 'all'), $city))
                    ->values();
                // City-first ranking: keep local relevance while preserving enough content volume.
                $items = $cityMatched->concat($otherItems)->values();
            }
        }

        $items = $items->map(fn (array $item) => $this->shapeFeedItem($item))->values();

        $slice = $items->slice($start, $safeLimit)->values();
        $end = $start + $slice->count();
        $hasMore = $end < $items->count();

        return response()->json([
            'data' => $slice,
            'meta' => [
                'next_cursor' => $hasMore ? (string) $end : null,
                'has_more' => $hasMore,
                'city' => $city === '' ? null : $city,
                'tag' => $tag === '' ? null : $tag,
                'boost_tag' => $boostTag === '' ? null : $boostTag,
                'boost_tag_secondary' => $boostTagSecondary === '' ? null : $boostTagSecondary,
                'city_matched_count' => $cityMatchedCount,
                'ranker' => $rankerMode,
            ],
        ]);
    }

    private function resolveRankerMode(string $ranker): string
    {
        $ranker = strtolower(trim($ranker));
        if ($ranker === 'on' || $ranker === 'weighted') {
            return 'weighted';
        }
        if ($ranker === 'off' || $ranker === 'legacy') {
            return 'legacy';
        }
        $enabled = (bool) config('home_content.ranker.enabled', true);
        return $enabled ? 'weighted' : 'legacy';
    }

    private function cityMatched(string $itemCity, string $userCity): bool
    {
        $itemCity = trim($itemCity);
        $userCity = trim($userCity);
        if ($itemCity === '' || strtolower($itemCity) === 'all') {
            return true;
        }
        if ($userCity === '') {
            return true;
        }
        $itemNorm = $this->normalizeCity($itemCity);
        $userNorm = $this->normalizeCity($userCity);
        return str_contains($userNorm, $itemNorm) || str_contains($itemNorm, $userNorm);
    }

    private function normalizeCity(string $city): string
    {
        $raw = strtolower(trim($city));
        $aliases = [
            'beijing' => '北京',
            'shanghai' => '上海',
            'guangzhou' => '广州',
            'shenzhen' => '深圳',
            'nanyang' => '南阳',
            '北京市' => '北京',
            '上海市' => '上海',
            '广州市' => '广州',
            '深圳市' => '深圳',
            '南阳市' => '南阳',
        ];
        return $aliases[$raw] ?? str_replace(' ', '', $raw);
    }

    /**
     * @param array<string,mixed> $item
     */
    private function relevanceScore(
        array $item,
        string $scene,
        string $tab,
        string $city,
        string $tag,
        string $boostTag = '',
        string $boostTagSecondary = ''
    ): int
    {
        $weights = (array) config('home_content.ranker.weights', []);
        $wTagQuery = (int) ($weights['tag_query_match'] ?? 120);
        $wBoostTag = (int) ($weights['boost_tag_match'] ?? 36);
        $wBoostTag2 = (int) ($weights['boost_tag_secondary_match'] ?? 18);
        $wCity = (int) ($weights['city_match'] ?? 80);
        $wTabTag = (int) ($weights['tab_semantic_tag'] ?? 15);
        $wScene = (int) ($weights['scene_hint'] ?? 6);
        $likesDivisor = max(1, (int) ($weights['likes_divisor'] ?? 10));

        $score = 0;
        $tags = collect($item['tags'] ?? [])
            ->map(fn ($v) => trim((string) $v))
            ->filter(fn ($v) => $v !== '')
            ->all();

        // 1) Explicit tag query is strongest signal.
        if ($tag !== '' && in_array($tag, $tags, true)) {
            $score += $wTagQuery;
        }
        if ($boostTag !== '' && in_array($boostTag, $tags, true)) {
            $score += $wBoostTag;
        }
        if ($boostTagSecondary !== '' && in_array($boostTagSecondary, $tags, true)) {
            $score += $wBoostTag2;
        }

        // 2) City relevance.
        if ($city !== '' && $this->cityMatched((string) ($item['city'] ?? 'all'), $city)) {
            $score += $wCity;
        }

        // 3) Tab semantic tag boost.
        $tabTagBoost = [
            'recommend' => ['关系研究', '匹配提升'],
            'nearby' => ['同城', '活动', '轻活动'],
            'topic' => ['话题', '沟通技巧', '热点'],
            'event' => ['活动', '同城', '破冰'],
            'inspire' => ['灵感', '沟通技巧', '关系研究'],
            'hot' => ['热点', '话题', '投票'],
            'local' => ['同城', '活动', '轻活动'],
            'live' => ['语音房', '沟通技巧', '关系研究'],
        ];
        foreach (($tabTagBoost[$tab] ?? []) as $t) {
            if (in_array($t, $tags, true)) {
                $score += $wTabTag;
            }
        }

        // 4) Mild scene fit fallback.
        if ($scene === 'discover' && in_array('热点', $tags, true)) {
            $score += $wScene;
        }
        if ($scene === 'home' && in_array('关系研究', $tags, true)) {
            $score += $wScene;
        }

        // 5) Keep likes as tiny tie-breaker.
        $score += max(0, (int) ($item['likes'] ?? 0)) / $likesDivisor;

        return $score;
    }

    private function shapeFeedItem(array $item): array
    {
        return [
            'id' => (string) ($item['id'] ?? ''),
            'title' => (string) ($item['title'] ?? ''),
            'summary' => (string) ($item['summary'] ?? ''),
            'author' => (string) ($item['author'] ?? '系统'),
            'likes' => (int) ($item['likes'] ?? 0),
            'city' => (string) ($item['city'] ?? 'all'),
            'tags' => array_values(array_filter((array) ($item['tags'] ?? []), fn ($v) => trim((string) $v) !== '')),
            'media' => array_values(array_filter((array) ($item['media'] ?? []), fn ($v) => trim((string) $v) !== '')),
            'body' => (string) ($item['body'] ?? ''),
        ];
    }
}
