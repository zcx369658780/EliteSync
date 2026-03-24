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
        'score_personality_total',
        'score_mbti_total',
        'score_astro_total',
        'score_overall',
        'score_bazi',
        'score_zodiac',
        'score_constellation',
        'score_natal_chart',
        'match_verdict',
        'match_reasons',
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
            'match_reasons' => 'array',
            'score_base' => 'integer',
            'score_final' => 'integer',
            'score_fair' => 'integer',
            'score_personality_total' => 'integer',
            'score_mbti_total' => 'integer',
            'score_astro_total' => 'integer',
            'score_overall' => 'integer',
            'score_bazi' => 'integer',
            'score_zodiac' => 'integer',
            'score_constellation' => 'integer',
            'score_natal_chart' => 'integer',
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
