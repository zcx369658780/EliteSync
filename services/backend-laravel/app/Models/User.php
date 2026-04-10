<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Relations\HasMany;
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
        'role',
        'account_type',
        'verify_status',
        'realname_verified',
        'disabled',
        'moderation_status',
        'moderation_note',
        'is_synthetic',
        'synthetic_batch',
        'synthetic_batch_id',
        'synthetic_seed',
        'generation_version',
        'account_status',
        'visibility_scope',
        'cleanup_token',
        'is_match_eligible',
        'is_square_visible',
        'exclude_from_metrics',
        'banned_reason',
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
            'role' => 'string',
            'account_type' => 'string',
            'disabled' => 'boolean',
            'is_synthetic' => 'boolean',
            'synthetic_seed' => 'integer',
            'is_match_eligible' => 'boolean',
            'is_square_visible' => 'boolean',
            'exclude_from_metrics' => 'boolean',
            'realname_verified' => 'boolean',
            'public_personality' => 'array',
            'private_natal_chart' => 'array',
            'private_ziwei' => 'array',
        ];
    }

    public function isAdminRole(): bool
    {
        return ($this->role ?? 'user') === 'admin';
    }

    public function isTestAccount(): bool
    {
        return ($this->account_type ?? 'normal') === 'test' || (bool) $this->is_synthetic;
    }

    public function astroProfile(): HasOne
    {
        return $this->hasOne(UserAstroProfile::class);
    }

    public function moderationReports()
    {
        return $this->hasMany(ModerationReport::class, 'reporter_id');
    }

    public function receivedReports()
    {
        return $this->hasMany(ModerationReport::class, 'target_user_id');
    }

    public function blocks()
    {
        return $this->hasMany(UserBlock::class, 'blocker_id');
    }

    public function blockedBy()
    {
        return $this->hasMany(UserBlock::class, 'blocked_user_id');
    }

    public function statusPosts(): HasMany
    {
        return $this->hasMany(StatusPost::class, 'author_user_id');
    }
}
