<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserAstroProfile extends Model
{
    protected $fillable = [
        'user_id',
        'birth_time',
        'birth_place',
        'birth_lat',
        'birth_lng',
        'sun_sign',
        'moon_sign',
        'asc_sign',
        'bazi',
        'true_solar_time',
        'da_yun',
        'liu_nian',
        'wu_xing',
        'notes',
        'computed_at',
    ];

    protected function casts(): array
    {
        return [
            'birth_lat' => 'float',
            'birth_lng' => 'float',
            'da_yun' => 'array',
            'liu_nian' => 'array',
            'wu_xing' => 'array',
            'notes' => 'array',
            'computed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
