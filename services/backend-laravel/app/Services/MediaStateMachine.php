<?php

namespace App\Services;

class MediaStateMachine
{
    public const STATUSES = [
        'pending',
        'uploading',
        'uploaded',
        'processing',
        'ready',
        'failed',
        'blocked',
        'deleted',
    ];

    public function statuses(): array
    {
        return self::STATUSES;
    }

    public function canTransition(string $from, string $to): bool
    {
        return in_array($to, $this->allowedTransitions($from), true);
    }

    public function allowedTransitions(string $from): array
    {
        return match ($from) {
            'pending' => ['uploading', 'blocked', 'deleted'],
            'uploading' => ['uploaded', 'failed', 'blocked', 'deleted'],
            'uploaded' => ['processing', 'ready', 'failed', 'blocked', 'deleted'],
            'processing' => ['ready', 'failed', 'blocked', 'deleted'],
            'ready' => ['blocked', 'deleted'],
            'failed' => ['uploading', 'blocked', 'deleted'],
            'blocked' => ['deleted'],
            'deleted' => [],
            default => [],
        };
    }

    public function normalize(string $status): string
    {
        $normalized = strtolower(trim($status));

        return in_array($normalized, self::STATUSES, true) ? $normalized : 'pending';
    }
}
