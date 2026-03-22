<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MbtiAttempt extends Model
{
    protected $fillable = [
        'user_id',
        'version_code',
        'answers_json',
        'score_json',
        'confidence_json',
        'tie_break_log_json',
        'result_letters',
        'submitted_at',
    ];

    protected function casts(): array
    {
        return [
            'answers_json' => 'array',
            'score_json' => 'array',
            'confidence_json' => 'array',
            'tie_break_log_json' => 'array',
            'submitted_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

