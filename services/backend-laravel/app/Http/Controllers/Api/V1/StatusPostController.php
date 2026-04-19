<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use App\Models\ModerationReport;
use App\Models\StatusPost;
use App\Models\StatusPostLike;
use App\Models\User;
use App\Services\EventLogger;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class StatusPostController extends Controller
{
    /**
     * Build a safe author projection that tolerates older schemas where the
     * 3.1 account-layer columns may not exist yet.
     *
     * @param  array<string, mixed>  $fallbacks
     * @return array<int, string|\Illuminate\Database\Query\Expression>
     */
    private function safeAuthorSelect(array $fallbacks = []): array
    {
        $columns = ['id', 'phone', 'name'];

        foreach ($fallbacks as $column => $fallback) {
            if (Schema::hasColumn('users', $column)) {
                $columns[] = $column;
                continue;
            }

            $columns[] = DB::raw($this->sqlLiteral($fallback).' as '.$column);
        }

        return $columns;
    }

    private function sqlLiteral(mixed $value): string
    {
        if ($value === null) {
            return 'NULL';
        }

        if (is_bool($value)) {
            return $value ? '1' : '0';
        }

        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }

        return DB::connection()->getPdo()->quote((string) $value);
    }

    /**
     * @return array<string, mixed>
     */
    private function shapeMediaAsset(?MediaAsset $asset): array
    {
        if (!$asset) {
            return [];
        }

        return [
            'id' => (int) $asset->id,
            'media_type' => (string) $asset->media_type,
            'storage_provider' => (string) $asset->storage_provider,
            'storage_disk' => (string) $asset->storage_disk,
            'storage_key' => (string) $asset->storage_key,
            'mime_type' => (string) ($asset->mime_type ?? ''),
            'size_bytes' => (int) ($asset->size_bytes ?? 0),
            'status' => (string) $asset->status,
            'error_code' => (string) ($asset->error_code ?? ''),
            'error_message' => (string) ($asset->error_message ?? ''),
            'public_url' => (string) ($asset->public_url ?? ''),
            'width' => $asset->width,
            'height' => $asset->height,
            'duration_ms' => $asset->duration_ms,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function shapeAuthor(?User $author): array
    {
        return [
            'id' => (int) ($author?->id ?? 0),
            'name' => (string) ($author?->nickname ?? $author?->name ?? $author?->phone ?? ''),
            'nickname' => (string) ($author?->nickname ?? ''),
            'phone' => (string) ($author?->phone ?? ''),
            'role' => (string) ($author?->role ?? 'user'),
            'account_type' => (string) ($author?->account_type ?? 'normal'),
            'is_synthetic' => (bool) ($author?->is_synthetic ?? false),
            'is_square_visible' => (bool) ($author?->is_square_visible ?? true),
            'city' => (string) ($author?->city ?? ''),
            'relationship_goal' => (string) ($author?->relationship_goal ?? ''),
            'public_mbti' => (string) ($author?->public_mbti ?? ''),
            'public_personality' => (array) ($author?->public_personality ?? []),
        ];
    }

    /**
     * @return Builder<StatusPost>
     */
    private function visibleFeedQuery(?int $viewerId, bool $viewerIsAdmin, bool $includeHidden = false): Builder
    {
        $query = StatusPost::query()
            ->with([
                'author' => function ($query) {
                    $query->select($this->safeAuthorSelect([
                        'nickname' => '',
                        'city' => '',
                        'relationship_goal' => '',
                        'public_mbti' => '',
                        'public_personality' => null,
                        'role' => 'user',
                        'account_type' => 'normal',
                        'is_synthetic' => false,
                        'is_square_visible' => true,
                    ]));
                },
                'coverMediaAsset',
            ])
            ->withCount('likes')
            ->withCount([
                'likes as viewer_liked_count' => function ($query) use ($viewerId) {
                    if ($viewerId !== null) {
                        $query->where('user_id', $viewerId);
                    } else {
                        $query->whereRaw('1 = 0');
                    }
                },
            ])
            ->orderByDesc('id');

        if ($includeHidden && $viewerIsAdmin) {
            return $query;
        }

        $query->where('is_deleted', false)
            ->where(function ($q) use ($viewerId) {
                $q->whereIn('visibility', ['public', 'square']);
                if ($viewerId !== null) {
                    $q->orWhere('author_user_id', $viewerId);
                }
            })
            ->whereHas('author', function ($q) use ($viewerId) {
                $q->where('disabled', false)
                    ->where(function ($inner) use ($viewerId) {
                        $inner->where('is_square_visible', true);
                        if ($viewerId !== null) {
                            $inner->orWhere('id', $viewerId);
                        }
                    });
            });

        if ($viewerId !== null) {
            $query
                ->whereNotExists(function ($sub) use ($viewerId) {
                    $sub->select(DB::raw(1))
                        ->from('user_blocks as blocker')
                        ->whereColumn('blocker.blocker_id', 'status_posts.author_user_id')
                        ->where('blocker.blocked_user_id', $viewerId);
                })
                ->whereNotExists(function ($sub) use ($viewerId) {
                    $sub->select(DB::raw(1))
                        ->from('user_blocks as blocked')
                        ->where('blocked.blocker_id', $viewerId)
                        ->whereColumn('blocked.blocked_user_id', 'status_posts.author_user_id');
                });
        }

        return $query;
    }

    private function shapePost(StatusPost $post, ?int $viewerId = null, bool $viewerIsAdmin = false): array
    {
        $author = $post->author;
        $coverMedia = $post->coverMediaAsset;
        $canDelete = $viewerIsAdmin || ($viewerId !== null && (int) $author?->id === $viewerId);

        $media = [];
        if ($coverMedia && (string) ($coverMedia->public_url ?? '') !== '') {
            $media[] = (string) $coverMedia->public_url;
        }

        return [
            'id' => (int) $post->id,
            'title' => (string) $post->title,
            'body' => (string) $post->body,
            'location_name' => (string) ($post->location_name ?? ''),
            'visibility' => (string) ($post->visibility ?? 'public'),
            'is_deleted' => (bool) $post->is_deleted,
            'can_delete' => $canDelete,
            'likes_count' => (int) ($post->likes_count ?? 0),
            'liked_by_viewer' => (bool) ((int) ($post->viewer_liked_count ?? 0) > 0),
            'cover_media_asset_id' => $post->cover_media_asset_id ? (int) $post->cover_media_asset_id : null,
            'media' => $media,
            'cover_media' => $this->shapeMediaAsset($coverMedia),
            'created_at' => optional($post->created_at)?->toIso8601String(),
            'updated_at' => optional($post->updated_at)?->toIso8601String(),
            'deleted_at' => optional($post->deleted_at)?->toIso8601String(),
            'author' => $this->shapeAuthor($author),
        ];
    }

    private function visibleStatusQueryForPost(int $postId, ?int $viewerId, bool $viewerIsAdmin): Builder
    {
        return $this->visibleFeedQuery($viewerId, $viewerIsAdmin)
            ->where('id', $postId);
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $viewerId = $user?->id !== null ? (int) $user->id : null;
        $viewerIsAdmin = $user?->isAdminRole() ?? false;
        $limit = max(1, min((int) $request->query('limit', 20), 50));
        $cursor = max(0, (int) $request->query('cursor', 0));
        $includeHidden = $viewerIsAdmin && $request->boolean('include_hidden', false);

        $query = $this->visibleFeedQuery($viewerId, $viewerIsAdmin, $includeHidden);

        $countQuery = clone $query;
        $total = $countQuery->count();

        $items = $query
            ->skip($cursor)
            ->take($limit)
            ->get()
            ->map(fn (StatusPost $post) => $this->shapePost($post, $viewerId, $viewerIsAdmin))
            ->values();

        $nextCursor = ($cursor + $items->count()) < $total ? (string) ($cursor + $items->count()) : null;

        return response()->json([
            'items' => $items,
            'meta' => [
                'next_cursor' => $nextCursor,
                'has_more' => $nextCursor !== null,
                'total' => $total,
            ],
        ]);
    }

    public function show(Request $request, int $postId): JsonResponse
    {
        $user = $request->user();
        $viewerId = $user?->id !== null ? (int) $user->id : null;
        $viewerIsAdmin = $user?->isAdminRole() ?? false;

        $post = $this->visibleStatusQueryForPost($postId, $viewerId, $viewerIsAdmin)
            ->first();

        if (!$post) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'item' => $this->shapePost($post, $viewerId, $viewerIsAdmin),
        ]);
    }

    public function author(Request $request, int $userId): JsonResponse
    {
        $viewer = $request->user();
        $viewerId = $viewer?->id !== null ? (int) $viewer->id : null;
        $viewerIsAdmin = $viewer?->isAdminRole() ?? false;

        $author = User::query()
            ->select($this->safeAuthorSelect([
                'nickname' => '',
                'city' => '',
                'relationship_goal' => '',
                'public_mbti' => '',
                'public_personality' => null,
                'role' => 'user',
                'account_type' => 'normal',
                'is_synthetic' => false,
                'is_square_visible' => true,
            ]))
            ->find($userId);

        if (!$author) {
            return response()->json(['message' => 'author not found'], 404);
        }

        if (!$viewerIsAdmin && (bool) $author->disabled) {
            return response()->json(['message' => 'author not found'], 404);
        }

        if (!$viewerIsAdmin && $viewerId !== $userId && !(bool) ($author->is_square_visible ?? true)) {
            return response()->json(['message' => 'author not found'], 404);
        }

        $postsQuery = $this->visibleFeedQuery($viewerId, $viewerIsAdmin)
            ->where('author_user_id', $userId);

        $items = $postsQuery
            ->orderByDesc('id')
            ->limit(10)
            ->get()
            ->map(fn (StatusPost $post) => $this->shapePost($post, $viewerId, $viewerIsAdmin))
            ->values();

        return response()->json([
            'ok' => true,
            'author' => $this->shapeAuthor($author),
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if (($user?->disabled ?? false) || (($user?->moderation_status ?? 'normal') === 'banned')) {
            return response()->json(['message' => 'account blocked'], 403);
        }

        $data = $request->validate([
            'title' => ['required', 'string', 'max:120'],
            'body' => ['required', 'string', 'max:500'],
            'location_name' => ['nullable', 'string', 'max:120'],
            'visibility' => ['nullable', 'string', 'in:public,square,private'],
            'cover_media_asset_id' => ['nullable', 'integer', 'exists:media_assets,id'],
        ]);

        $location = trim((string) ($data['location_name'] ?? ''));
        if ($location === '') {
            $location = trim((string) ($user?->city ?? $user?->private_birth_place ?? ''));
        }

        $coverMediaAssetId = null;
        if (!empty($data['cover_media_asset_id'])) {
            $coverAsset = MediaAsset::query()
                ->where('id', (int) $data['cover_media_asset_id'])
                ->where('owner_user_id', (int) $user->id)
                ->first();

            if (!$coverAsset) {
                return response()->json(['message' => 'cover media not found'], 422);
            }

            if (!str_starts_with((string) $coverAsset->media_type, 'image')) {
                return response()->json(['message' => 'cover media must be an image'], 422);
            }

            if (!in_array((string) $coverAsset->status, ['uploaded', 'ready'], true)) {
                return response()->json(['message' => 'cover media is not ready'], 422);
            }

            $coverMediaAssetId = (int) $coverAsset->id;
        }

        $post = StatusPost::create([
            'author_user_id' => (int) $user->id,
            'cover_media_asset_id' => $coverMediaAssetId,
            'title' => trim($data['title']),
            'body' => trim($data['body']),
            'location_name' => $location === '' ? null : $location,
            'visibility' => $data['visibility'] ?? 'public',
            'is_deleted' => false,
            'deleted_by_user_id' => null,
            'deleted_at' => null,
        ])->load([
            'author' => function ($query) {
                $query->select($this->safeAuthorSelect([
                    'nickname' => '',
                    'city' => '',
                    'relationship_goal' => '',
                    'public_mbti' => '',
                    'public_personality' => null,
                    'role' => 'user',
                    'account_type' => 'normal',
                    'is_synthetic' => false,
                    'is_square_visible' => true,
                ]));
            },
            'coverMediaAsset',
        ]);

        return response()->json([
            'ok' => true,
            'item' => $this->shapePost($post, (int) $user->id, $user?->isAdminRole() ?? false),
        ], 201);
    }

    public function like(Request $request, int $postId, EventLogger $events): JsonResponse
    {
        return $this->toggleLike($request, $postId, true, $events);
    }

    public function unlike(Request $request, int $postId, EventLogger $events): JsonResponse
    {
        return $this->toggleLike($request, $postId, false, $events);
    }

    private function toggleLike(Request $request, int $postId, bool $liked, EventLogger $events): JsonResponse
    {
        $user = $request->user();
        $viewerId = (int) $user->id;
        $post = $this->visibleStatusQueryForPost($postId, $viewerId, $user?->isAdminRole() ?? false)->first();
        if (!$post) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        if ($liked) {
            StatusPostLike::query()->firstOrCreate([
                'status_post_id' => (int) $post->id,
                'user_id' => $viewerId,
            ]);
        } else {
            StatusPostLike::query()
                ->where('status_post_id', (int) $post->id)
                ->where('user_id', $viewerId)
                ->delete();
        }

        $events->log(
            eventName: $liked ? 'status_post_like' : 'status_post_unlike',
            actorUserId: $viewerId,
            targetUserId: (int) $post->author_user_id,
            payload: [
                'status_post_id' => (int) $post->id,
                'liked' => $liked,
                'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
            ]
        );

        $fresh = $this->visibleStatusQueryForPost($postId, $viewerId, $user?->isAdminRole() ?? false)->firstOrFail();

        return response()->json([
            'ok' => true,
            'item' => $this->shapePost($fresh, $viewerId, $user?->isAdminRole() ?? false),
        ]);
    }

    public function report(Request $request, int $postId, EventLogger $events): JsonResponse
    {
        $user = $request->user();
        $viewerId = (int) $user->id;
        $post = $this->visibleStatusQueryForPost($postId, $viewerId, $user?->isAdminRole() ?? false)->first();
        if (!$post) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        $data = $request->validate([
            'reason_code' => ['required', 'string', 'max:64'],
            'detail' => ['nullable', 'string', 'max:2000'],
        ]);

        $report = ModerationReport::create([
            'reporter_id' => $viewerId,
            'target_user_id' => (int) $post->author_user_id,
            'target_status_post_id' => (int) $post->id,
            'category' => 'status_post',
            'reason_code' => $data['reason_code'],
            'detail' => $data['detail'] ?? null,
            'status' => 'new',
            'appeal_status' => 'none',
        ]);

        $events->log(
            eventName: 'status_post_report',
            actorUserId: $viewerId,
            targetUserId: (int) $post->author_user_id,
            payload: [
                'status_post_id' => (int) $post->id,
                'reason_code' => (string) $data['reason_code'],
                'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
            ]
        );

        return response()->json([
            'ok' => true,
            'report' => [
                'id' => $report->id,
                'status' => $report->status,
                'appeal_status' => $report->appeal_status,
            ],
        ]);
    }

    public function destroy(Request $request, int $postId): JsonResponse
    {
        $user = $request->user();
        $post = StatusPost::query()
            ->with([
                'author' => function ($query) {
                    $query->select($this->safeAuthorSelect([
                        'nickname' => '',
                        'city' => '',
                        'relationship_goal' => '',
                        'public_mbti' => '',
                        'public_personality' => null,
                        'role' => 'user',
                        'account_type' => 'normal',
                        'is_synthetic' => false,
                        'is_square_visible' => true,
                    ]));
                },
                'coverMediaAsset',
            ])
            ->find($postId);

        if (!$post) {
            return response()->json(['message' => 'status post not found'], 404);
        }

        $viewerIsAdmin = $user?->isAdminRole() ?? false;
        $isOwner = (int) $post->author_user_id === (int) $user?->id;
        if (!$viewerIsAdmin && !$isOwner) {
            return response()->json(['message' => 'forbidden'], 403);
        }

        $post->is_deleted = true;
        $post->deleted_by_user_id = (int) $user->id;
        $post->deleted_at = now();
        $post->save();

        return response()->json([
            'ok' => true,
            'item' => $this->shapePost(
                $post->fresh([
                    'author' => function ($query) {
                        $query->select($this->safeAuthorSelect([
                            'nickname' => '',
                            'city' => '',
                            'relationship_goal' => '',
                            'public_mbti' => '',
                            'public_personality' => null,
                            'role' => 'user',
                            'account_type' => 'normal',
                            'is_synthetic' => false,
                            'is_square_visible' => true,
                        ]));
                    },
                    'coverMediaAsset',
                ]),
                (int) $user->id,
                $viewerIsAdmin
            ),
        ]);
    }
}
