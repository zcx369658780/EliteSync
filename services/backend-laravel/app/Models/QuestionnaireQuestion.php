<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class QuestionnaireQuestion extends Model
{
    use HasFactory;

    protected $fillable = [
        'question_key',
        'category',
        'subtopic',
        'recommended_bank',
        'quality_tier',
        'quality_tag',
        'quality_reason',
        'content',
        'question_text_zh',
        'question_text_en',
        'question_type',
        'acceptable_answer_logic',
        'options',
        'sort_order',
        'enabled',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'options' => 'array',
            'enabled' => 'boolean',
            'version' => 'integer',
        ];
    }

    public function answers(): HasMany
    {
        return $this->hasMany(QuestionnaireAnswer::class);
    }
}
