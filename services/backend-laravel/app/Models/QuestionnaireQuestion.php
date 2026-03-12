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
        'content',
        'question_type',
        'options',
        'sort_order',
        'enabled',
    ];

    protected function casts(): array
    {
        return [
            'options' => 'array',
            'enabled' => 'boolean',
        ];
    }

    public function answers(): HasMany
    {
        return $this->hasMany(QuestionnaireAnswer::class);
    }
}
