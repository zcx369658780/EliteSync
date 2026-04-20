<?php

namespace App\Console\Commands;

use App\Models\MediaProcessingJob;
use Illuminate\Console\Command;

class MediaProcessQueueCommand extends Command
{
    protected $signature = 'app:media:process-queue
        {--limit=20 : Maximum queued jobs to inspect}
        {--dry-run : Only print job status without updating rows}';

    protected $description = 'Process media queue skeleton jobs for 4.0C.';

    public function handle(): int
    {
        $limit = max(1, (int) $this->option('limit'));
        $jobs = MediaProcessingJob::query()
            ->with('mediaAsset')
            ->where('status', 'queued')
            ->orderBy('id')
            ->limit($limit)
            ->get();

        $this->line('queued_jobs=' . $jobs->count());
        $dryRun = (bool) $this->option('dry-run');

        foreach ($jobs as $job) {
            $asset = $job->mediaAsset;
            $this->line(sprintf(
                'job#%d asset#%d type=%s asset_status=%s',
                $job->id,
                (int) ($asset?->id ?? 0),
                $job->job_type,
                (string) ($asset?->status ?? 'missing')
            ));

            if ($dryRun) {
                continue;
            }

            if (!$asset) {
                $job->forceFill([
                    'status' => 'failed',
                    'error_code' => 'asset_missing',
                    'error_message' => 'media asset not found',
                    'processed_at' => now(),
                ])->save();
                continue;
            }

            if ($asset->status === 'uploaded' || !empty($asset->public_url)) {
                $asset->forceFill([
                    'status' => 'ready',
                    'processed_at' => now(),
                ])->save();
                $job->forceFill([
                    'status' => 'succeeded',
                    'processed_at' => now(),
                ])->save();
                continue;
            }

            $job->forceFill([
                'attempt_count' => (int) $job->attempt_count + 1,
                'error_code' => 'awaiting_upload',
                'error_message' => 'asset has not been uploaded yet',
            ])->save();
        }

        return self::SUCCESS;
    }
}
