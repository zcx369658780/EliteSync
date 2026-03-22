<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSecureTransport
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!config('security.enforce_https', false)) {
            return $next($request);
        }

        $isSecure = $request->isSecure()
            || strtolower((string) $request->header('X-Forwarded-Proto')) === 'https'
            || strtolower((string) $request->server('HTTP_X_FORWARDED_PROTO')) === 'https';

        if (!$isSecure) {
            return response()->json([
                'ok' => false,
                'error' => [
                    'code' => 'https_required',
                    'message' => 'HTTPS is required.',
                    'details' => null,
                ],
            ], 426);
        }

        return $next($request);
    }
}
