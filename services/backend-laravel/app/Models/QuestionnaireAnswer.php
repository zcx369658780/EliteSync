<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuestionnaireAnswer extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'questionnaire_question_id',
        'answer_payload',
        'selected_answer_json',
        'acceptable_answers_json',
        'importance',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'answer_payload' => 'array',
            'selected_answer_json' => 'array',
            'acceptable_answers_json' => 'array',
            'importance' => 'integer',
            'version' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function question(): BelongsTo
    {
        return $this->belongsTo(QuestionnaireQuestion::class, 'questionnaire_question_id');
    }
}
