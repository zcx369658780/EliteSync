<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuestionnaireAttempt extends Model
{
    protected $fillable = [
        'user_id',
        'questionnaire_version',
        'bank_version',
        'attempt_version',
        'answers_count',
        'total_count',
        'answers_json',
        'profile_json',
        'summary_json',
        'result_label',
        'result_highlights_json',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'answers_count' => 'integer',
            'total_count' => 'integer',
            'answers_json' => 'array',
            'profile_json' => 'array',
            'summary_json' => 'array',
            'result_highlights_json' => 'array',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
