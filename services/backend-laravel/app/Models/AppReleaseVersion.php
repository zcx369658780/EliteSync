<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppReleaseVersion extends Model
{
    use HasFactory;

    protected $fillable = [
        'platform',
        'channel',
        'version_name',
        'version_code',
        'min_supported_version_name',
        'download_url',
        'changelog',
        'sha256',
        'force_update',
        'is_active',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'version_code' => 'integer',
            'force_update' => 'boolean',
            'is_active' => 'boolean',
            'published_at' => 'datetime',
        ];
    }
}

