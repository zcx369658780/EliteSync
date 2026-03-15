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
        'explanation_tags',
        'score_base',
        'score_final',
        'score_fair',
        'penalty_factors',
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
            'explanation_tags' => 'array',
            'penalty_factors' => 'array',
            'score_base' => 'integer',
            'score_final' => 'integer',
            'score_fair' => 'integer',
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
