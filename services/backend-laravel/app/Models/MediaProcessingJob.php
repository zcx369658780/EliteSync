<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MediaProcessingJob extends Model
{
    use HasFactory;

    protected $fillable = [
        'media_asset_id',
        'job_type',
        'status',
        'attempt_count',
        'max_attempts',
        'locked_at',
        'processed_at',
        'error_code',
        'error_message',
        'payload',
    ];

    protected function casts(): array
    {
        return [
            'attempt_count' => 'integer',
            'max_attempts' => 'integer',
            'payload' => 'array',
            'locked_at' => 'datetime',
            'processed_at' => 'datetime',
        ];
    }

    public function mediaAsset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'media_asset_id');
    }
}
