<?php

namespace App\Services;

use com\nlf\calendar\Solar;

class LunarPhpBaziEngine implements BaziEngine
{
    /**
     * @param array<string,mixed> $payload
     */
    public function canonicalize(array $payload): array
    {
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $gender = trim((string) ($payload['gender'] ?? ''));

        if ($birthday === '' || $birthTime === '') {
            return $this->fallback($payload, 'missing_birthday_or_birth_time');
        }

        [$year, $month, $day] = $this->parseDate($birthday);
        [$hour, $minute] = $this->parseTime($birthTime);
        if ($year === null || $month === null || $day === null || $hour === null || $minute === null) {
            return $this->fallback($payload, 'invalid_birthday_or_birth_time');
        }

        try {
            $solar = Solar::fromYmdHms($year, $month, $day, $hour, $minute, 0);
            $lunar = $solar->getLunar();
            $eight = $lunar->getEightChar();
        } catch (\Throwable) {
            return $this->fallback($payload, 'lunar_engine_exception');
        }

        $bazi = trim((string) $eight->toString());
        $sunSign = $this->normalizeSunSign((string) $solar->getXingZuo());
        $wuXing = $this->buildWuXing($eight);
        $genderFlag = strtolower($gender) === 'female' ? 0 : 1;
        $yun = $eight->getYun($genderFlag);
        $daYunRaw = (array) $yun->getDaYunBy(8);
        $daYun = $this->buildDaYun($daYunRaw);
        $liuNian = $this->buildLiuNian($daYunRaw);
        $notes = array_values(array_filter(array_merge(
            (array) ($payload['notes'] ?? []),
            ['canonical_source:lunar_php', 'precision:calendar_canonical']
        )));

        $hasLat = array_key_exists('birth_lat', $payload) && $payload['birth_lat'] !== null;
        $hasLng = array_key_exists('birth_lng', $payload) && $payload['birth_lng'] !== null;
        $confidence = 0.88;
        if (!$hasLat || !$hasLng) {
            $confidence = min($confidence, (float) config('confidence_policy.astro.no_birth_location.confidence_cap', 0.65));
            $notes[] = 'confidence_policy:no_birth_location';
        }

        return [
            'sun_sign' => $sunSign,
            'moon_sign' => $this->nullable($payload['moon_sign'] ?? null),
            'asc_sign' => $this->nullable($payload['asc_sign'] ?? null),
            'bazi' => $bazi !== '' ? $bazi : $this->nullable($payload['bazi'] ?? null),
            'true_solar_time' => $this->nullable($payload['true_solar_time'] ?? null),
            'da_yun' => $daYun,
            'liu_nian' => $liuNian,
            'wu_xing' => $wuXing,
            'notes' => $notes,
            'accuracy' => (string) config('astro_canonical.labels.server_engine', 'canonical_server'),
            'confidence' => max(0.0, min(1.0, $confidence)),
        ];
    }

    /**
     * @return array{0:?int,1:?int,2:?int}
     */
    private function parseDate(string $birthday): array
    {
        if (!preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $birthday, $m)) {
            return [null, null, null];
        }
        return [(int) $m[1], (int) $m[2], (int) $m[3]];
    }

    /**
     * @return array{0:?int,1:?int}
     */
    private function parseTime(string $birthTime): array
    {
        if (!preg_match('/^(\d{2}):(\d{2})$/', $birthTime, $m)) {
            return [null, null];
        }
        return [(int) $m[1], (int) $m[2]];
    }

    private function normalizeSunSign(string $sign): string
    {
        $s = trim($sign);
        if ($s === '') {
            return '';
        }
        return str_ends_with($s, '座') ? $s : ($s.'座');
    }

    /**
     * @return array<string,int>
     */
    private function buildWuXing(mixed $eight): array
    {
        $score = ['木' => 0.0, '火' => 0.0, '土' => 0.0, '金' => 0.0, '水' => 0.0];

        $pairs = [
            (string) $eight->getYearWuXing(),
            (string) $eight->getMonthWuXing(),
            (string) $eight->getDayWuXing(),
            (string) $eight->getTimeWuXing(),
        ];
        foreach ($pairs as $pair) {
            foreach (preg_split('//u', $pair, -1, PREG_SPLIT_NO_EMPTY) ?: [] as $ch) {
                if (isset($score[$ch])) {
                    $score[$ch] += 1.0;
                }
            }
        }

        $stemToWuXing = [
            '甲' => '木', '乙' => '木',
            '丙' => '火', '丁' => '火',
            '戊' => '土', '己' => '土',
            '庚' => '金', '辛' => '金',
            '壬' => '水', '癸' => '水',
        ];
        $hideGan = array_merge(
            (array) $eight->getYearHideGan(),
            (array) $eight->getMonthHideGan(),
            (array) $eight->getDayHideGan(),
            (array) $eight->getTimeHideGan()
        );
        foreach ($hideGan as $gan) {
            $k = (string) $gan;
            if (isset($stemToWuXing[$k])) {
                $score[$stemToWuXing[$k]] += 0.5;
            }
        }

        return [
            '木' => (int) round($score['木'] * 10),
            '火' => (int) round($score['火'] * 10),
            '土' => (int) round($score['土'] * 10),
            '金' => (int) round($score['金'] * 10),
            '水' => (int) round($score['水'] * 10),
        ];
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    private function buildDaYun(array $all): array
    {
        $rows = [];
        foreach ($all as $dy) {
            $index = (int) $dy->getIndex();
            if ($index <= 0) {
                continue;
            }
            $rows[] = [
                'index' => $index,
                'gan_zhi' => (string) $dy->getGanZhi(),
                'start_year' => (int) $dy->getStartYear(),
                'end_year' => (int) $dy->getEndYear(),
                'start_age' => (int) $dy->getStartAge(),
                'end_age' => (int) $dy->getEndAge(),
            ];
        }
        return $rows;
    }

    /**
     * @param array<int,mixed> $daYunRaw
     * @return array<int,array<string,mixed>>
     */
    private function buildLiuNian(array $daYunRaw): array
    {
        if (empty($daYunRaw)) {
            return [];
        }
        $year = (int) date('Y');
        $hit = null;
        foreach ($daYunRaw as $dy) {
            $index = (int) $dy->getIndex();
            if ($index <= 0) {
                continue;
            }
            $sy = (int) $dy->getStartYear();
            $ey = (int) $dy->getEndYear();
            if ($sy <= $year && $year <= $ey) {
                $hit = $dy;
                break;
            }
        }
        if ($hit === null) {
            foreach ($daYunRaw as $dy) {
                if ((int) $dy->getIndex() > 0) {
                    $hit = $dy;
                    break;
                }
            }
        }
        if ($hit === null) {
            return [];
        }

        $liuNianRaw = (array) $hit->getLiuNianBy(10);
        $rows = [];
        foreach ($liuNianRaw as $ln) {
            $rows[] = [
                'year' => (int) $ln->getYear(),
                'age' => (int) $ln->getAge(),
                'gan_zhi' => (string) $ln->getGanZhi(),
            ];
        }
        return $rows;
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    private function fallback(array $payload, string $reason): array
    {
        $legacy = new LegacyClientBaziEngine();
        $out = $legacy->canonicalize($payload);
        $notes = (array) ($out['notes'] ?? []);
        $notes[] = 'canonical_fallback:'.$reason;
        $out['notes'] = array_values(array_unique($notes));
        return $out;
    }

    private function nullable(mixed $value): ?string
    {
        $v = trim((string) ($value ?? ''));
        return $v === '' ? null : $v;
    }
}
