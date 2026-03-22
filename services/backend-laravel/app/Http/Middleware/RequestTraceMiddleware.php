<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class RequestTraceMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $requestId = $request->headers->get('X-Request-Id') ?: (string) Str::uuid();
        $request->attributes->set('request_id', $requestId);
        $startedAt = microtime(true);

        /** @var Response $response */
        $response = $next($request);

        $latencyMs = (int) ((microtime(true) - $startedAt) * 1000);
        $route = $request->route();

        Log::info('api_request', [
            'request_id' => $requestId,
            'method' => $request->method(),
            'path' => $request->path(),
            'route' => $route ? $route->uri() : null,
            'status' => $response->getStatusCode(),
            'latency_ms' => $latencyMs,
            'user_id' => optional($request->user())->id,
            'ip' => $request->ip(),
        ]);

        $response->headers->set('X-Request-Id', $requestId);

        return $response;
    }
}

