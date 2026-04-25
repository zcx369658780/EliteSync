<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RtcSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'call_key',
        'room_key',
        'initiator_user_id',
        'peer_user_id',
        'mode',
        'status',
        'accepted_by_user_id',
        'ended_by_user_id',
        'ringing_at',
        'accepted_at',
        'started_at',
        'initiator_last_seen_at',
        'peer_last_seen_at',
        'ended_at',
        'expires_at',
        'failure_code',
        'failure_message',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'ringing_at' => 'datetime',
            'accepted_at' => 'datetime',
            'started_at' => 'datetime',
            'initiator_last_seen_at' => 'datetime',
            'peer_last_seen_at' => 'datetime',
            'ended_at' => 'datetime',
            'expires_at' => 'datetime',
            'metadata' => 'array',
        ];
    }

    public function initiator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'initiator_user_id');
    }

    public function peer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'peer_user_id');
    }

    public function acceptedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'accepted_by_user_id');
    }

    public function endedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'ended_by_user_id');
    }

    public function events(): HasMany
    {
        return $this->hasMany(RtcSessionEvent::class, 'rtc_session_id');
    }
}
