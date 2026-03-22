<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Crypt;
use Throwable;

class ChatMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'room_id',
        'sender_id',
        'receiver_id',
        'content',
        'is_read',
        'read_at',
    ];

    protected function casts(): array
    {
        return [
            'is_read' => 'boolean',
            'read_at' => 'datetime',
        ];
    }

    public function setContentAttribute(?string $value): void
    {
        $plain = trim((string) $value);
        $this->attributes['content'] = $plain === '' ? '' : Crypt::encryptString($plain);
    }

    public function getContentAttribute(?string $value): string
    {
        if ($value === null || $value === '') {
            return '';
        }

        // Backward-compatible read path for legacy plaintext rows.
        try {
            return Crypt::decryptString($value);
        } catch (Throwable) {
            return $value;
        }
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }
}
