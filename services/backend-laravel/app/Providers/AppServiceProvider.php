<?php

namespace App\Providers;

use App\Services\BaziEngine;
use App\Services\BirthLocationSolarTimeService;
use App\Services\LegacyInputWesternNatalEngine;
use App\Services\LunarPhpBaziEngine;
use App\Services\LegacyClientBaziEngine;
use App\Services\ZiweiCanonicalService;
use App\Services\WesternNatalEngine;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(BaziEngine::class, function () {
            // Phase 1 bootstrap:
            // switch canonical engine via config.
            $engine = (string) config('astro_canonical.engine', 'legacy_client');
            if ($engine === 'lunar_php' || $engine === 'server_engine') {
                return new LunarPhpBaziEngine();
            }
            if ($engine === 'legacy_client') {
                return new LegacyClientBaziEngine();
            }
            // Unknown engine name: fail-safe fallback.
            return new LunarPhpBaziEngine();
        });

        $this->app->bind(WesternNatalEngine::class, function () {
            $engine = strtolower(trim((string) config('western_natal.engine', 'legacy_input')));
            /** @var \App\Services\AstrologyDependencyGateService $gate */
            $gate = app(\App\Services\AstrologyDependencyGateService::class);
            $licenseKey = match ($engine) {
                'swisseph' => 'swisseph',
                'pyswisseph' => 'pyswisseph',
                'kerykeion' => 'kerykeion',
                default => null,
            };
            if ($licenseKey !== null) {
                $allow = $gate->allow($licenseKey);
                if (!(bool) ($allow['allowed'] ?? false)) {
                    return new LegacyInputWesternNatalEngine();
                }
            }
            // Phase-3 preparation: non-legacy engines are not implemented yet,
            // keep fallback stable and switch implementation later without changing interface.
            return new LegacyInputWesternNatalEngine();
        });

        $this->app->singleton(ZiweiCanonicalService::class, fn () => new ZiweiCanonicalService(app(\App\Services\AstroCanonicalRolloutService::class)));
        $this->app->singleton(BirthLocationSolarTimeService::class, fn () => new BirthLocationSolarTimeService());
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('auth', function (Request $request) {
            $phone = (string) $request->input('phone', '');
            $ip = (string) $request->ip();

            return [
                Limit::perMinute(10)->by('auth:phone:'.$phone),
                Limit::perMinute(30)->by('auth:ip:'.$ip),
            ];
        });

        RateLimiter::for('messages', function (Request $request) {
            $uid = (string) optional($request->user())->id;
            $ip = (string) $request->ip();

            return [
                Limit::perMinute(60)->by('msg:user:'.$uid),
                Limit::perMinute(120)->by('msg:ip:'.$ip),
            ];
        });

        RateLimiter::for('conversations', function (Request $request) {
            $uid = (string) optional($request->user())->id;
            $ip = (string) $request->ip();

            return [
                Limit::perMinute(30)->by('conv:user:'.$uid),
                Limit::perMinute(60)->by('conv:ip:'.$ip),
            ];
        });

        RateLimiter::for('media', function (Request $request) {
            $uid = (string) optional($request->user())->id;
            $ip = (string) $request->ip();

            return [
                Limit::perMinute(20)->by('media:user:'.$uid),
                Limit::perMinute(40)->by('media:ip:'.$ip),
            ];
        });

        RateLimiter::for('relationships', function (Request $request) {
            $uid = (string) optional($request->user())->id;
            $ip = (string) $request->ip();

            return [
                Limit::perMinute(20)->by('rel:user:'.$uid),
                Limit::perMinute(40)->by('rel:ip:'.$ip),
            ];
        });

        RateLimiter::for('notifications', function (Request $request) {
            $uid = (string) optional($request->user())->id;
            $ip = (string) $request->ip();

            return [
                Limit::perMinute(60)->by('notify:user:'.$uid),
                Limit::perMinute(120)->by('notify:ip:'.$ip),
            ];
        });
    }
}
