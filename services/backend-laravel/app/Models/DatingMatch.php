<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DatingMatch extends Model
{
    use HasFactory;

    protected $fillable = [
        'week_tag',
        'user_a',
        'user_b',
        'highlights',
        'drop_released',
        'like_a',
        'like_b',
    ];

    protected function casts(): array
    {
        return [
            'drop_released' => 'boolean',
            'like_a' => 'boolean',
            'like_b' => 'boolean',
        ];
    }

    public function userA(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_a');
    }

    public function userB(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_b');
    }
}
