<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StatusPostLike extends Model
{
    use HasFactory;

    protected $fillable = [
        'status_post_id',
        'user_id',
    ];

    public function statusPost(): BelongsTo
    {
        return $this->belongsTo(StatusPost::class, 'status_post_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
