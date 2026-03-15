<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_name',
        'actor_user_id',
        'target_user_id',
        'match_id',
        'payload',
    ];

    protected function casts(): array
    {
        return [
            'payload' => 'array',
        ];
    }
}

