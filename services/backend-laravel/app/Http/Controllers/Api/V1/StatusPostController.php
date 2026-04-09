<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\StatusPost;
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

    private function shapePost(StatusPost $post, ?int $viewerId = null, bool $viewerIsAdmin = false): array
    {
        $author = $post->author;
        $canDelete = $viewerIsAdmin || ($viewerId !== null && (int) $author?->id === $viewerId);

        return [
            'id' => (int) $post->id,
            'title' => (string) $post->title,
            'body' => (string) $post->body,
            'location_name' => (string) ($post->location_name ?? ''),
            'visibility' => (string) ($post->visibility ?? 'public'),
            'is_deleted' => (bool) $post->is_deleted,
            'can_delete' => $canDelete,
            'created_at' => optional($post->created_at)?->toIso8601String(),
            'updated_at' => optional($post->updated_at)?->toIso8601String(),
            'deleted_at' => optional($post->deleted_at)?->toIso8601String(),
            'author' => [
                'id' => (int) ($author?->id ?? 0),
                'name' => (string) ($author?->name ?? ''),
                'phone' => (string) ($author?->phone ?? ''),
                'role' => (string) ($author?->role ?? 'user'),
                'account_type' => (string) ($author?->account_type ?? 'normal'),
                'is_square_visible' => (bool) ($author?->is_square_visible ?? true),
            ],
        ];
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $viewerId = $user?->id !== null ? (int) $user->id : null;
        $viewerIsAdmin = $user?->isAdminRole() ?? false;
        $limit = max(1, min((int) $request->query('limit', 20), 50));
        $cursor = max(0, (int) $request->query('cursor', 0));
        $includeHidden = $viewerIsAdmin && $request->boolean('include_hidden', false);

        $query = StatusPost::query()
            ->with([
                'author' => function ($query) {
                    $query->select($this->safeAuthorSelect([
                        'role' => 'user',
                        'account_type' => 'normal',
                        'is_square_visible' => true,
                    ]));
                },
            ])
            ->orderByDesc('id');

        if (!$includeHidden) {
            $query->where('is_deleted', false)
                ->whereHas('author', function ($q) use ($viewerId) {
                    $q->where('disabled', false)
                        ->where(function ($inner) use ($viewerId) {
                            $inner->where('is_square_visible', true);
                            if ($viewerId !== null) {
                                $inner->orWhere('id', $viewerId);
                            }
                        });
                })
                ->where(function ($q) use ($viewerId) {
                    $q->whereIn('visibility', ['public', 'square']);
                    if ($viewerId !== null) {
                        $q->orWhere('author_user_id', $viewerId);
                    }
                });
        }

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
        ]);

        $location = trim((string) ($data['location_name'] ?? ''));
        if ($location === '') {
            $location = trim((string) ($user?->city ?? $user?->private_birth_place ?? ''));
        }

        $post = StatusPost::create([
            'author_user_id' => (int) $user->id,
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
                    'role' => 'user',
                    'account_type' => 'normal',
                    'is_square_visible' => true,
                ]));
            },
        ]);

        return response()->json([
            'ok' => true,
            'item' => $this->shapePost($post, (int) $user->id, $user?->isAdminRole() ?? false),
        ], 201);
    }

    public function destroy(Request $request, int $postId): JsonResponse
    {
        $user = $request->user();
        $post = StatusPost::query()
            ->with([
                'author' => function ($query) {
                    $query->select($this->safeAuthorSelect([
                        'role' => 'user',
                        'account_type' => 'normal',
                        'is_square_visible' => true,
                    ]));
                },
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
                            'role' => 'user',
                            'account_type' => 'normal',
                            'is_square_visible' => true,
                        ]));
                    },
                ]),
                (int) $user->id,
                $viewerIsAdmin
            ),
        ]);
    }
}
