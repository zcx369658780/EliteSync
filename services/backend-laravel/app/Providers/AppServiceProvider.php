<?php

namespace App\Providers;

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
        //
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
    }
}
