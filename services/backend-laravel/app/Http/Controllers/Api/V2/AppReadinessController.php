<?php

namespace App\Http\Controllers\Api\V2;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class AppReadinessController extends Controller
{
    public function __invoke(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'status' => 'not_ready',
                'production_ready' => false,
                'checks' => [
                    'database' => [
                        'status' => 'not_allowed_in_first_slice',
                    ],
                    'redis' => [
                        'status' => 'not_allowed_in_first_slice',
                    ],
                    'queue' => [
                        'status' => 'worker_not_resident',
                        'evidence' => 'carry_over',
                    ],
                    'monitoring' => [
                        'status' => 'not_configured',
                        'evidence' => 'carry_over',
                    ],
                    'backup' => [
                        'status' => 'planning_only',
                        'evidence' => 'not_executed',
                    ],
                    'load_test' => [
                        'status' => 'not_executed',
                    ],
                ],
                'reason' => 'conservative readiness only; DB, Redis, monitoring, backup, and load-test evidence are not executed in this slice',
            ],
            'meta' => [
                'notice' => 'readiness is not production readiness and performs no DB, Redis, storage, auth, or user data access',
            ],
        ]);
    }
}
