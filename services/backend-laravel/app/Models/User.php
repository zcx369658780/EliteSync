<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'birthday',
        'zodiac_animal',
        'gender',
        'city',
        'relationship_goal',
        'password',
        'verify_status',
        'realname_verified',
        'disabled',
        'is_synthetic',
        'synthetic_batch',
        'public_zodiac_sign',
        'public_mbti',
        'public_personality',
        'private_bazi',
        'private_natal_chart',
        'private_ziwei',
        'private_birth_place',
        'private_birth_lat',
        'private_birth_lng',
    ];

    /**
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'birthday' => 'date',
            'password' => 'hashed',
            'disabled' => 'boolean',
            'is_synthetic' => 'boolean',
            'realname_verified' => 'boolean',
            'public_personality' => 'array',
            'private_natal_chart' => 'array',
            'private_ziwei' => 'array',
        ];
    }

    public function astroProfile(): HasOne
    {
        return $this->hasOne(UserAstroProfile::class);
    }
}
