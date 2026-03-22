<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminPhone
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($this->allowPublicDevMatching($request)) {
            return $next($request);
        }

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

    private function allowPublicDevMatching(Request $request): bool
    {
        if (!(bool) config('app.allow_public_dev_matching', true)) {
            return false;
        }

        return $request->is('api/v1/admin/dev/run-matching')
            || $request->is('api/v1/admin/dev/release-drop');
    }
}
