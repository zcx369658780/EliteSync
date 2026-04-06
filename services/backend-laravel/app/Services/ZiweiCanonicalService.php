<?php

namespace App\Services;

class ZiweiCanonicalService
{
    private const PALACES = [
        '命宫', '兄弟宫', '夫妻宫', '子女宫', '财帛宫', '疾厄宫',
        '迁移宫', '仆役宫', '官禄宫', '田宅宫', '福德宫', '父母宫',
    ];

    private const MAIN_STARS = [
        '紫微', '天机', '太阳', '武曲', '天同', '廉贞',
        '天府', '太阴', '贪狼', '巨门', '天相', '天梁',
        '七杀', '破军',
    ];

    private const AUX_STARS = [
        '左辅', '右弼', '文昌', '文曲', '禄存', '擎羊', '陀罗', '火星', '铃星', '天空', '地劫', '天魁', '天钺',
    ];

    public function __construct(private readonly AstroCanonicalRolloutService $rollout)
    {
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    public function canonicalize(array $payload): array
    {
        $decision = $this->rollout->decideZiwei($payload);
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $trueSolarTime = trim((string) ($payload['true_solar_time'] ?? ''));
        $effectiveBirthTime = $trueSolarTime !== '' ? $trueSolarTime : $birthTime;
        $birthPlace = trim((string) ($payload['birth_place'] ?? ''));
        $locationShiftMinutes = (int) ($payload['location_shift_minutes'] ?? 0);
        $positionSignature = trim((string) ($payload['position_signature'] ?? ''));
        $gender = strtolower(trim((string) ($payload['gender'] ?? '')));

        if ($birthday === '') {
            return $this->fallback($payload, 'missing_birthday', $decision);
        }

        [$year, $month, $day] = $this->parseDate($birthday);
        [$hour, $minute] = $this->parseTime($effectiveBirthTime);
        if ($year === null || $month === null || $day === null) {
            return $this->fallback($payload, 'invalid_birthday', $decision);
        }

        $seed = ($year * 10000) + ($month * 100) + $day + ($hour ?? 0) * 3 + (int) floor(($minute ?? 0) / 10);
        $seed += $locationShiftMinutes;
        if ($positionSignature !== '') {
            $seed += abs(crc32($positionSignature)) % 12;
        }
        $lifeIndex = $this->mod1to12($seed);
        $bodyIndex = $this->mod1to12($seed + 5 + (($gender === 'female') ? 1 : 0));
        $lifePalace = self::PALACES[$lifeIndex - 1];
        $bodyPalace = self::PALACES[$bodyIndex - 1];
        $mingBodyGap = abs($lifeIndex - $bodyIndex);
        $mingBodyGap = min($mingBodyGap, 12 - $mingBodyGap);

        $palaces = [];
        foreach (self::PALACES as $i => $palace) {
            $rotation = $this->rotate(self::MAIN_STARS, $seed + $i);
            $mainStar = $rotation[0];
            $secondary = array_slice($rotation, 1, 2);
            $aux = array_slice($this->rotate(self::AUX_STARS, $seed + ($i * 2)), 0, 3);
            $palaces[] = [
                'index' => $i + 1,
                'name' => $palace,
                'main_star' => $mainStar,
                'secondary_stars' => array_values($secondary),
                'auxiliary_stars' => array_values($aux),
                'strength' => $this->palaceStrength($i + 1, $lifeIndex, $bodyIndex),
                'summary' => $this->palaceSummary($palace, $mainStar, $lifeIndex, $bodyIndex),
            ];
        }

        $majorThemes = [
            'life_palace' => $lifePalace,
            'body_palace' => $bodyPalace,
            'life_body_gap' => $mingBodyGap,
            'career_bias' => $this->palaceFromIndex($seed + 8),
            'wealth_bias' => $this->palaceFromIndex($seed + 4),
            'relationship_bias' => $this->palaceFromIndex($seed + 2),
        ];

        $notes = array_values(array_filter(array_merge(
            (array) ($payload['notes'] ?? []),
            [
                'canonical_source:ziwei_server',
                'precision:birth_datetime_seeded',
                'module:ziwei',
                'ziwei_rollout:'.(string) ($decision['reason'] ?? 'unknown'),
                $birthPlace !== '' ? 'birth_place_present:1' : 'birth_place_present:0',
                $effectiveBirthTime !== '' ? 'time_source:true_solar_time_or_birth_time' : 'time_source:missing',
                'location_shift_minutes:'.(string) $locationShiftMinutes,
            ]
        )));

        $confidence = 0.84;
        if ($effectiveBirthTime === '') {
            $confidence = min($confidence, 0.68);
            $notes[] = 'confidence_policy:no_birth_time';
        }
        if ($birthPlace === '') {
            $confidence = min($confidence, 0.64);
            $notes[] = 'confidence_policy:no_birth_location';
        }

        return [
            'ziwei' => [
                'life_palace' => $lifePalace,
                'body_palace' => $bodyPalace,
                'major_themes' => $majorThemes,
                'palaces' => $palaces,
                'summary' => $this->summaryText($lifePalace, $bodyPalace, $mingBodyGap),
                'engine' => 'ziwei_canonical_server',
                'precision' => $effectiveBirthTime === '' ? 'date_only' : ($birthPlace === '' ? 'no_location' : 'full_birth_data'),
                'confidence' => $confidence,
            ],
            'notes' => $notes,
            'accuracy' => 'canonical_server',
            'confidence' => $confidence,
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
        if ($birthTime === '') {
            return [null, null];
        }
        if (!preg_match('/^(\d{2}):(\d{2})$/', $birthTime, $m)) {
            return [null, null];
        }
        return [(int) $m[1], (int) $m[2]];
    }

    private function mod1to12(int $value): int
    {
        $m = $value % 12;
        return $m <= 0 ? $m + 12 : $m;
    }

    /**
     * @param list<string> $items
     * @return list<string>
     */
    private function rotate(array $items, int $offset): array
    {
        if (empty($items)) {
            return [];
        }
        $count = count($items);
        $shift = $offset % $count;
        if ($shift < 0) {
            $shift += $count;
        }
        return array_values(array_merge(array_slice($items, $shift), array_slice($items, 0, $shift)));
    }

    private function palaceFromIndex(int $value): string
    {
        $index = $this->mod1to12($value);
        return self::PALACES[$index - 1];
    }

    private function palaceStrength(int $index, int $lifeIndex, int $bodyIndex): string
    {
        if ($index === $lifeIndex || $index === $bodyIndex) {
            return 'high';
        }
        if (abs($index - $lifeIndex) <= 2 || abs($index - $bodyIndex) <= 2) {
            return 'medium';
        }
        return 'normal';
    }

    private function palaceSummary(string $palace, string $mainStar, int $lifeIndex, int $bodyIndex): string
    {
        $base = match ($palace) {
            '命宫' => '命宫主轴体现个人气质与行事风格',
            '夫妻宫' => '夫妻宫反映关系中对亲密与承诺的表达',
            '财帛宫' => '财帛宫偏向资源配置与消费习惯',
            '官禄宫' => '官禄宫体现工作路径与责任感',
            '福德宫' => '福德宫体现内在稳定感与恢复能力',
            default => '该宫位反映相关主题的倾向',
        };
        $bias = abs($lifeIndex - $bodyIndex) <= 2 ? '，命身同频程度较高' : '，命身分离度较明显';
        return "{$mainStar}落在{$palace}：{$base}{$bias}";
    }

    private function summaryText(string $lifePalace, string $bodyPalace, int $gap): string
    {
        return sprintf('命宫落在%s，身宫落在%s，命身差距为%d宫位，适合用于长期画像解释。', $lifePalace, $bodyPalace, $gap);
    }

    /**
     * @param array<string,mixed> $payload
     * @param array{enabled:bool,reason:string} $decision
     * @return array<string,mixed>
     */
    private function fallback(array $payload, string $reason, array $decision): array
    {
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $seed = crc32($birthday.'|'.$birthTime.'|'.(string) ($payload['user_id'] ?? 0));
        $lifeIndex = $this->mod1to12((int) $seed);
        $bodyIndex = $this->mod1to12((int) $seed + 5);

        return [
            'ziwei' => [
                'life_palace' => $this->palaceFromIndex($lifeIndex),
                'body_palace' => $this->palaceFromIndex($bodyIndex),
                'major_themes' => [
                    'life_palace' => $this->palaceFromIndex($lifeIndex),
                    'body_palace' => $this->palaceFromIndex($bodyIndex),
                    'life_body_gap' => abs($lifeIndex - $bodyIndex),
                    'career_bias' => $this->palaceFromIndex($seed + 8),
                    'wealth_bias' => $this->palaceFromIndex($seed + 4),
                    'relationship_bias' => $this->palaceFromIndex($seed + 2),
                ],
                'palaces' => [],
                'summary' => '紫微斗数信息不完整，当前采用保守估计。',
                'engine' => 'ziwei_canonical_server',
                'precision' => 'degraded_fallback',
                'confidence' => 0.56,
            ],
            'notes' => array_values(array_filter(array_merge(
                (array) ($payload['notes'] ?? []),
                [
                    'canonical_source:ziwei_server',
                    'canonical_fallback:'.$reason,
                    'ziwei_rollout:'.(string) ($decision['reason'] ?? 'unknown'),
                ]
            ))),
            'accuracy' => 'canonical_server',
            'confidence' => 0.56,
        ];
    }
}
