<?php

use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->append(\App\Http\Middleware\RequestTraceMiddleware::class);
        $middleware->prependToGroup('api', \App\Http\Middleware\ForceJsonResponse::class);
        $middleware->alias([
            'admin.phone' => \App\Http\Middleware\EnsureAdminPhone::class,
            'secure.transport' => \App\Http\Middleware\EnsureSecureTransport::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (Throwable $e, $request) {
            if (!$request->is('api/*')) {
                return null;
            }

            $status = 500;
            $code = 'internal_error';
            $message = 'Server error';
            $details = null;

            if ($e instanceof ValidationException) {
                $status = 422;
                $code = 'validation_error';
                $message = $e->getMessage() ?: 'The given data was invalid.';
                $details = $e->errors();
            } elseif ($e instanceof AuthenticationException) {
                $status = 401;
                $code = 'unauthenticated';
                $message = 'Unauthenticated.';
            } elseif ($e instanceof AuthorizationException) {
                $status = 403;
                $code = 'forbidden';
                $message = $e->getMessage() ?: 'Forbidden.';
            } elseif ($e instanceof HttpExceptionInterface) {
                $status = $e->getStatusCode();
                $code = 'http_error';
                $message = $e->getMessage() ?: 'HTTP error';
            } else {
                $message = config('app.debug') ? $e->getMessage() : $message;
            }

            $payload = [
                'ok' => false,
                'error' => [
                    'code' => $code,
                    'message' => $message,
                    'details' => $details,
                ],
            ];

            return response()->json($payload, $status);
        });
    })->create();
