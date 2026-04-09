<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StatusPost extends Model
{
    use HasFactory;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'author_user_id',
        'title',
        'body',
        'location_name',
        'visibility',
        'is_deleted',
        'deleted_by_user_id',
        'deleted_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_deleted' => 'boolean',
            'deleted_at' => 'datetime',
        ];
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_user_id');
    }

    public function deletedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'deleted_by_user_id');
    }
}
