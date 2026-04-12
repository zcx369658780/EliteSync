<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class PythonAstroRenderService
{
    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>|null
     */
    public function request(string $path, array $payload): ?array
    {
        $base = trim((string) config('python_astro.api_base', ''));
        if ($base === '') {
            $base = trim((string) preg_replace('~/render/?$~', '', (string) config('python_astro.render_url', '')));
        }
        if ($base === '') {
            return null;
        }

        $url = rtrim($base, '/') . '/' . ltrim($path, '/');
        $timeout = (int) config('python_astro.timeout_seconds', 20);

        try {
            $response = Http::timeout($timeout)
                ->acceptJson()
                ->asJson()
                ->post($url, $payload);
        } catch (\Throwable $e) {
            return null;
        }

        if (! $response->successful()) {
            return null;
        }

        $json = $response->json();
        if (! is_array($json)) {
            return null;
        }

        $profile = data_get($json, 'profile');
        if (is_array($profile)) {
            return $profile;
        }

        return $json;
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>|null
     */
    public function render(array $payload): ?array
    {
        return $this->request('/render', $payload);
    }
}
