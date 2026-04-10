<?php

namespace App\Console\Commands;

use App\Models\AppReleaseVersion;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class AppReleaseUpsertCommand extends Command
{
    protected $signature = 'app:release:upsert
        {--platform=android : Platform (android|ios)}
        {--channel=stable : Release channel}
        {--version-name= : Version name, e.g. 0.01.05}
        {--version-code= : Version code, e.g. 105}
        {--min-supported-version-name= : Min supported version}
        {--download-url= : Download URL}
        {--changelog= : Changelog text}
        {--changelog-b64= : Base64 encoded changelog text (UTF-8), preferred for shells}
        {--sha256= : APK SHA256}
        {--force-update=0 : Force update flag (0|1|true|false)}';

    protected $description = 'Upsert app release metadata into app_release_versions and keep single active release per platform/channel.';

    public function handle(): int
    {
        $platform = (string) $this->option('platform');
        $channel = (string) $this->option('channel');
        $versionName = trim((string) $this->option('version-name'));
        $versionCodeRaw = $this->option('version-code');
        $minSupported = trim((string) $this->option('min-supported-version-name'));
        $downloadUrl = trim((string) $this->option('download-url'));
        $sha256 = strtoupper(trim((string) $this->option('sha256')));
        $forceRaw = strtolower((string) $this->option('force-update'));

        if (!in_array($platform, ['android', 'ios'], true)) {
            $this->error('Invalid --platform. Use android or ios.');
            return self::FAILURE;
        }
        if ($versionName === '' || !preg_match('/^\d+\.\d+\.\d+[a-z]*$/i', $versionName)) {
            $this->error('Invalid --version-name. Expected major.minor.patch or major.minor.patch[suffix]');
            return self::FAILURE;
        }
        if ($versionCodeRaw === null || !is_numeric((string) $versionCodeRaw) || (int) $versionCodeRaw <= 0) {
            $this->error('Invalid --version-code. Must be positive integer.');
            return self::FAILURE;
        }
        if ($minSupported === '') {
            $minSupported = $versionName;
        }
        if ($downloadUrl === '') {
            $this->error('Missing --download-url.');
            return self::FAILURE;
        }

        $changelog = trim((string) $this->option('changelog'));
        $changelogB64 = trim((string) $this->option('changelog-b64'));
        if ($changelogB64 !== '') {
            $decoded = base64_decode($changelogB64, true);
            if ($decoded !== false) {
                $changelog = trim($decoded);
            }
        }

        $forceUpdate = in_array($forceRaw, ['1', 'true', 'yes', 'y', 'on'], true);
        $versionCode = (int) $versionCodeRaw;
        $publishedAt = now();

        DB::transaction(function () use (
            $platform,
            $channel,
            $versionCode,
            $versionName,
            $minSupported,
            $downloadUrl,
            $changelog,
            $sha256,
            $forceUpdate,
            $publishedAt
        ): void {
            AppReleaseVersion::query()
                ->where('platform', $platform)
                ->where('channel', $channel)
                ->where('is_active', true)
                ->update(['is_active' => false]);

            AppReleaseVersion::query()->updateOrCreate(
                [
                    'platform' => $platform,
                    'channel' => $channel,
                    'version_code' => $versionCode,
                ],
                [
                    'version_name' => $versionName,
                    'min_supported_version_name' => $minSupported,
                    'download_url' => $downloadUrl,
                    'changelog' => $changelog,
                    'sha256' => $sha256,
                    'force_update' => $forceUpdate,
                    'is_active' => true,
                    'published_at' => $publishedAt,
                ]
            );
        });

        $this->info(sprintf(
            'Release upserted: %s/%s %s (%d), force=%s',
            $platform,
            $channel,
            $versionName,
            $versionCode,
            $forceUpdate ? 'true' : 'false'
        ));
        $this->line('OK');
        return self::SUCCESS;
    }
}
