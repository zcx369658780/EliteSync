<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ModerationReport extends Model
{
    protected $fillable = [
        'reporter_id',
        'target_user_id',
        'target_message_id',
        'category',
        'reason_code',
        'detail',
        'status',
        'appeal_status',
        'appeal_note',
        'appealed_at',
        'admin_note',
        'resolved_by_user_id',
        'resolved_at',
    ];

    protected function casts(): array
    {
        return [
            'appealed_at' => 'datetime',
            'resolved_at' => 'datetime',
        ];
    }

    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    public function targetUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'target_user_id');
    }

    public function targetMessage(): BelongsTo
    {
        return $this->belongsTo(ChatMessage::class, 'target_message_id');
    }

    public function resolver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'resolved_by_user_id');
    }
}
