<?php

namespace App\Services;

class BaziDerivedZodiacService
{
    /**
     * 地支 -> 生肖
     *
     * @var array<string,string>
     */
    private const BRANCH_TO_ANIMAL = [
        '子' => '鼠',
        '丑' => '牛',
        '寅' => '虎',
        '卯' => '兔',
        '辰' => '龙',
        '巳' => '蛇',
        '午' => '马',
        '未' => '羊',
        '申' => '猴',
        '酉' => '鸡',
        '戌' => '狗',
        '亥' => '猪',
    ];

    public function fromYearPillar(?string $yearPillar): ?string
    {
        $p = trim((string) $yearPillar);
        if ($p === '') {
            return null;
        }

        if (preg_match('/([子丑寅卯辰巳午未申酉戌亥])/u', $p, $m) !== 1) {
            return null;
        }

        $branch = (string) ($m[1] ?? '');
        if ($branch === '') {
            return null;
        }

        return self::BRANCH_TO_ANIMAL[$branch] ?? null;
    }

    /**
     * 支持形如：
     * - 甲子年 丙寅月 丁卯日 庚午时
     * - 甲子 丙寅 丁卯 庚午
     */
    public function fromBaziString(?string $bazi): ?string
    {
        $text = trim((string) $bazi);
        if ($text === '') {
            return null;
        }

        if (preg_match('/([甲乙丙丁戊己庚辛壬癸]?)([子丑寅卯辰巳午未申酉戌亥])年/u', $text, $m) === 1) {
            return self::BRANCH_TO_ANIMAL[(string) ($m[2] ?? '')] ?? null;
        }

        $tokens = preg_split('/\s+/u', $text) ?: [];
        if (!empty($tokens)) {
            $first = (string) ($tokens[0] ?? '');
            $animal = $this->fromYearPillar($first);
            if ($animal !== null) {
                return $animal;
            }
        }

        return $this->fromYearPillar($text);
    }
}

