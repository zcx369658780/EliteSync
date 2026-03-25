<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\UserAstroMirrorService;
use Carbon\CarbonImmutable;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DevFillSyntheticAstroProfilesCommand extends Command
{
    protected $signature = 'app:dev:fill-synthetic-astro
        {--batch= : Only process one synthetic_batch}
        {--only-missing=1 : Fill only users missing astro core fields (0|1)}
        {--limit=0 : Max users to process (0 means no limit)}
        {--dry-run : Preview only, do not write}
        {--seed= : Optional mt_srand seed for reproducible random}';

    protected $description = 'Backfill synthetic users with astro profile fields (bazi/chart/place/time).';

    /**
     * @var array<int,array{name:string,lat:float,lng:float}>
     */
    private array $placePool = [
        ['name' => '北京市朝阳区', 'lat' => 39.9219, 'lng' => 116.4436],
        ['name' => '北京市海淀区', 'lat' => 39.9593, 'lng' => 116.2981],
        ['name' => '上海市浦东新区', 'lat' => 31.2304, 'lng' => 121.5444],
        ['name' => '上海市徐汇区', 'lat' => 31.1883, 'lng' => 121.4365],
        ['name' => '广州市天河区', 'lat' => 23.1356, 'lng' => 113.3610],
        ['name' => '广州市越秀区', 'lat' => 23.1292, 'lng' => 113.2668],
        ['name' => '深圳市南山区', 'lat' => 22.5333, 'lng' => 113.9304],
        ['name' => '深圳市福田区', 'lat' => 22.5410, 'lng' => 114.0545],
        ['name' => '南阳市卧龙区', 'lat' => 32.9899, 'lng' => 112.5289],
        ['name' => '南阳市宛城区', 'lat' => 32.9925, 'lng' => 112.5407],
    ];

    /** @var array<int,string> */
    private array $stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    /** @var array<int,string> */
    private array $branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    /** @var array<string,string> */
    private array $stemElement = [
        '甲' => '木', '乙' => '木',
        '丙' => '火', '丁' => '火',
        '戊' => '土', '己' => '土',
        '庚' => '金', '辛' => '金',
        '壬' => '水', '癸' => '水',
    ];
    /** @var array<string,string> */
    private array $branchElement = [
        '子' => '水', '丑' => '土', '寅' => '木', '卯' => '木',
        '辰' => '土', '巳' => '火', '午' => '火', '未' => '土',
        '申' => '金', '酉' => '金', '戌' => '土', '亥' => '水',
    ];
    /** @var array<int,string> */
    private array $zodiacSigns = ['白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座', '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'];

    private function ensureSyntheticOpsAllowed(): bool
    {
        if (!app()->environment('production')) {
            return true;
        }
        $allow = (bool) config('matching.debug.allow_synthetic_commands_in_production', false);
        if ($allow) {
            return true;
        }
        $this->error('Blocked in production: synthetic command is disabled. Set MATCHING_ALLOW_SYNTHETIC_COMMANDS_IN_PRODUCTION=true only for controlled operations.');
        return false;
    }

    public function handle(UserAstroMirrorService $mirror): int
    {
        if (!$this->ensureSyntheticOpsAllowed()) {
            return self::FAILURE;
        }

        $seed = $this->option('seed');
        if ($seed !== null && $seed !== '') {
            mt_srand((int) $seed);
        }

        $onlyMissing = in_array((string) $this->option('only-missing'), ['1', 'true', 'yes', 'on'], true);
        $dryRun = (bool) $this->option('dry-run');
        $limit = max(0, (int) $this->option('limit'));
        $batch = trim((string) $this->option('batch'));

        $q = User::query()
            ->where('is_synthetic', true)
            ->whereNotNull('birthday')
            ->when($batch !== '', function ($query) use ($batch) {
                $query->where('synthetic_batch', $batch);
            })
            ->orderBy('id');

        if ($onlyMissing) {
            $q->where(function ($qq) {
                $qq->whereDoesntHave('astroProfile')
                    ->orWhereHas('astroProfile', function ($aq) {
                        $aq->whereNull('bazi')
                            ->orWhereNull('sun_sign')
                            ->orWhereNull('birth_place');
                    });
            });
        }
        if ($limit > 0) {
            $q->limit($limit);
        }

        /** @var \Illuminate\Support\Collection<int,User> $users */
        $users = $q->get();
        if ($users->isEmpty()) {
            $this->warn('No synthetic users found for this filter.');
            return self::SUCCESS;
        }

        $this->line('users_selected='.$users->count());
        $this->line('dry_run='.($dryRun ? 'true' : 'false'));
        $this->line('only_missing='.($onlyMissing ? 'true' : 'false'));
        if ($batch !== '') {
            $this->line('batch='.$batch);
        }

        $updated = 0;
        $skipped = 0;

        if (!$dryRun) {
            DB::beginTransaction();
        }
        try {
            foreach ($users as $u) {
                $birthday = $u->birthday ? CarbonImmutable::parse((string) $u->birthday) : null;
                if (!$birthday) {
                    $skipped++;
                    continue;
                }

                $seedInt = ($u->id * 1103515245 + (int) $birthday->format('Ymd')) & 0x7fffffff;
                $sunSign = $this->sunSignFromBirthday($birthday);
                $moonSign = $this->pickBySeed($this->zodiacSigns, $seedInt + 7);
                $ascSign = $this->pickBySeed($this->zodiacSigns, $seedInt + 17);
                $place = $this->pickBySeed($this->placePool, $seedInt + 23);

                $birthTime = $this->randomBirthTime($seedInt + 31); // 01:00~23:59
                $trueSolarTime = $this->jitterTime($birthTime, $seedInt + 43);
                $bazi = $this->buildPseudoBazi($birthday, $seedInt + 59, $birthTime);
                $wuXing = $this->estimateWuXingFromBazi($bazi);
                $daYun = $this->buildDaYun($birthday, $seedInt + 71);
                $liuNian = $this->buildLiuNian($birthday, $seedInt + 79);

                if ($dryRun) {
                    $updated++;
                    continue;
                }

                $profile = UserAstroProfile::query()->updateOrCreate(
                    ['user_id' => (int) $u->id],
                    [
                        'birth_time' => $birthTime,
                        'birth_place' => $place['name'],
                        'birth_lat' => $place['lat'],
                        'birth_lng' => $place['lng'],
                        'sun_sign' => $sunSign,
                        'moon_sign' => $moonSign,
                        'asc_sign' => $ascSign,
                        'bazi' => $bazi,
                        'true_solar_time' => $trueSolarTime,
                        'da_yun' => $daYun,
                        'liu_nian' => $liuNian,
                        'wu_xing' => $wuXing,
                        'notes' => ['synthetic_auto_generated'],
                        'computed_at' => now(),
                    ]
                );

                $mirror->syncFromAstroProfile($u, $profile);

                $updated++;
            }

            if (!$dryRun) {
                DB::commit();
            }
        } catch (\Throwable $e) {
            if (!$dryRun) {
                DB::rollBack();
            }
            $this->error('fill synthetic astro failed: '.$e->getMessage());
            return self::FAILURE;
        }

        $this->info("updated={$updated}");
        $this->line("skipped={$skipped}");
        return self::SUCCESS;
    }

    private function sunSignFromBirthday(CarbonImmutable $birthday): string
    {
        $md = (int) $birthday->format('md');
        return match (true) {
            $md >= 321 && $md <= 419 => '白羊座',
            $md >= 420 && $md <= 520 => '金牛座',
            $md >= 521 && $md <= 621 => '双子座',
            $md >= 622 && $md <= 722 => '巨蟹座',
            $md >= 723 && $md <= 822 => '狮子座',
            $md >= 823 && $md <= 922 => '处女座',
            $md >= 923 && $md <= 1023 => '天秤座',
            $md >= 1024 && $md <= 1122 => '天蝎座',
            $md >= 1123 && $md <= 1221 => '射手座',
            $md >= 1222 || $md <= 119 => '摩羯座',
            $md >= 120 && $md <= 218 => '水瓶座',
            default => '双鱼座',
        };
    }

    private function randomBirthTime(int $seed): string
    {
        $h = $this->pseudoRand($seed, 1, 23);
        $m = $this->pseudoRand($seed + 1, 0, 59);
        return sprintf('%02d:%02d', $h, $m);
    }

    private function jitterTime(string $hhmm, int $seed): string
    {
        [$h, $m] = array_map('intval', explode(':', $hhmm));
        $baseMinutes = $h * 60 + $m;
        $offset = $this->pseudoRand($seed, -16, 16);
        $target = max(0, min(23 * 60 + 59, $baseMinutes + $offset));
        return sprintf('%02d:%02d', intdiv($target, 60), $target % 60);
    }

    private function buildPseudoBazi(CarbonImmutable $birthday, int $seed, string $birthTime): string
    {
        $year = (int) $birthday->format('Y');
        $month = (int) $birthday->format('n');
        $day = (int) $birthday->format('j');
        $hour = (int) substr($birthTime, 0, 2);

        $yearGz = $this->ganzhi(($year - 4) % 60);
        $monthGz = $this->ganzhi((($year * 12 + $month) + $seed) % 60);
        $dayGz = $this->ganzhi(((int) $birthday->format('z') + $seed) % 60);
        $hourGz = $this->ganzhi((($day * 12 + intdiv($hour, 2)) + $seed) % 60);

        return "{$yearGz}年 {$monthGz}月 {$dayGz}日 {$hourGz}时";
    }

    /**
     * @return array{木:int,火:int,土:int,金:int,水:int}
     */
    private function estimateWuXingFromBazi(string $bazi): array
    {
        $counts = ['木' => 0, '火' => 0, '土' => 0, '金' => 0, '水' => 0];
        $chars = preg_split('//u', $bazi, -1, PREG_SPLIT_NO_EMPTY) ?: [];
        foreach ($chars as $ch) {
            if (isset($this->stemElement[$ch])) {
                $counts[$this->stemElement[$ch]] += 2;
            } elseif (isset($this->branchElement[$ch])) {
                $counts[$this->branchElement[$ch]] += 1;
            }
        }
        foreach ($counts as $k => $v) {
            if ($v <= 0) {
                $counts[$k] = 1;
            }
        }
        return $counts;
    }

    /**
     * @return array<int,array{index:int,gan_zhi:string,start_year:int,end_year:int,start_age:int,end_age:int}>
     */
    private function buildDaYun(CarbonImmutable $birthday, int $seed): array
    {
        $startAge = $this->pseudoRand($seed, 3, 8);
        $startYear = (int) $birthday->format('Y') + $startAge;
        $base = (($seed % 60) + 60) % 60;
        $items = [];
        for ($i = 0; $i < 8; $i++) {
            $items[] = [
                'index' => $i,
                'gan_zhi' => $this->ganzhi($base + $i),
                'start_year' => $startYear + ($i * 10),
                'end_year' => $startYear + ($i * 10) + 9,
                'start_age' => $startAge + ($i * 10),
                'end_age' => $startAge + ($i * 10) + 9,
            ];
        }
        return $items;
    }

    /**
     * @return array<int,array{year:int,age:int,gan_zhi:string}>
     */
    private function buildLiuNian(CarbonImmutable $birthday, int $seed): array
    {
        $birthYear = (int) $birthday->format('Y');
        $currentYear = (int) now()->format('Y');
        $base = (($currentYear - 4) % 60 + 60) % 60;
        $items = [];
        for ($i = 0; $i < 12; $i++) {
            $year = $currentYear + $i;
            $items[] = [
                'year' => $year,
                'age' => max(0, $year - $birthYear),
                'gan_zhi' => $this->ganzhi($base + $i + ($seed % 3)),
            ];
        }
        return $items;
    }

    private function ganzhi(int $index): string
    {
        $i = (($index % 60) + 60) % 60;
        return $this->stems[$i % 10].$this->branches[$i % 12];
    }

    /**
     * @template T
     * @param array<int,T> $items
     * @return T
     */
    private function pickBySeed(array $items, int $seed)
    {
        $idx = $this->pseudoRand($seed, 0, max(0, count($items) - 1));
        return $items[$idx];
    }

    private function pseudoRand(int $seed, int $min, int $max): int
    {
        if ($min >= $max) {
            return $min;
        }
        $n = abs((int) (($seed * 1103515245 + 12345) & 0x7fffffff));
        return $min + ($n % ($max - $min + 1));
    }
}
