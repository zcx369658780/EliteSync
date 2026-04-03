<?php

namespace App\Support;

class ExplanationTemplateRegistry
{
    /**
     * @param array<string,mixed> $module
     * @return array<string,mixed>
     */
    public function resolve(array $module): array
    {
        $key = strtolower(trim((string) ($module['key'] ?? '')));
        $templates = $this->templates();
        return (array) ($templates[$key] ?? $templates['default']);
    }

    /**
     * @return array<string,array<string,mixed>>
     */
    private function templates(): array
    {
        return [
            'bazi' => [
                'summary_prefix' => '八字层结论：',
                'default_advice' => [
                    '优先对齐作息与冲突沟通节奏，再看长期稳定性是否提升。',
                    '遇到节律差异时，建议建立固定复盘机制。',
                ],
            ],
            'zodiac' => [
                'summary_prefix' => '属相层结论：',
                'default_advice' => [
                    '属相仅作辅助参考，优先观察真实互动质量。',
                ],
            ],
            'constellation' => [
                'summary_prefix' => '星座层结论：',
                'default_advice' => [
                    '星座更偏过程层表达风格，建议结合沟通反馈调整相处方式。',
                ],
            ],
            'natal_chart' => [
                'summary_prefix' => '星盘过程层结论：',
                'default_advice' => [
                    '优先关注情绪同步与表达节奏，避免只看单点分数。',
                ],
            ],
            'ziwei' => [
                'summary_prefix' => '紫微斗数长期画像结论：',
                'default_advice' => [
                    '紫微斗数更适合长期画像判断，建议结合命宫、身宫与主题落点综合理解。',
                ],
            ],
            'pair_chart' => [
                'summary_prefix' => '合盘关系层结论：',
                'default_advice' => [
                    '合盘反映关系气质与推进节奏，不等于单次互动结果。',
                ],
            ],
            'personality' => [
                'summary_prefix' => '人格层结论：',
                'default_advice' => [
                    '人格层优先用于沟通策略调整，不建议单独决定关系走向。',
                ],
            ],
            'mbti' => [
                'summary_prefix' => '性格测试层结论：',
                'default_advice' => [
                    '性格测试已关闭，当前仅保留历史兼容数据，不再作为排序依据。',
                ],
            ],
            'default' => [
                'summary_prefix' => '匹配层结论：',
                'default_advice' => [
                    '请结合真实互动结果理解该分项结论。',
                ],
            ],
        ];
    }
}
