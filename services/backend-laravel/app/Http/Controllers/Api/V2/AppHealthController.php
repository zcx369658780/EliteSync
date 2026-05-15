<?php

namespace App\Http\Controllers\Api\V2;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class AppHealthController extends Controller
{
    public function __invoke(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'status' => 'ok',
                'api_version' => 'v2',
                'service' => 'elitesync-backend',
                'runtime_stage' => '6.0-A1-narrow-v2-skeleton',
                'checks' => [
                    'database' => 'not_checked',
                    'redis' => 'not_checked',
                    'storage' => 'not_checked',
                ],
            ],
            'meta' => [
                'notice' => 'static health endpoint; no DB, Redis, storage, auth, or user data access',
            ],
        ]);
    }
}
