<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminPhone
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        $phones = config('app.admin_phones', []);

        if (app()->environment('local') && empty($phones)) {
            return $next($request);
        }

        if (!$user || !in_array((string) $user->phone, $phones, true)) {
            return response()->json(['message' => 'admin access required'], 403);
        }

        return $next($request);
    }
}

