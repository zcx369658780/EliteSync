<?php

namespace App\Support;

class ExplanationComposer
{
    public function __construct(
        private readonly ExplanationTemplateRegistry $registry
    ) {
    }

    /**
     * @param array<int,array<string,mixed>> $modules
     * @return array<int,array<string,mixed>>
     */
    public function compose(array $modules): array
    {
        $out = [];
        foreach ($modules as $module) {
            if (!is_array($module)) {
                continue;
            }
            $tpl = $this->registry->resolve($module);
            $label = trim((string) ($module['label'] ?? $module['key'] ?? '匹配项'));
            $summaryPrefix = (string) ($tpl['summary_prefix'] ?? '匹配层结论：');
            $reason = trim((string) ($module['reason'] ?? $module['reason_short'] ?? '暂无解释'));
            $risk = trim((string) ($module['risk'] ?? $module['risk_short'] ?? ''));

            $process = [];
            $processHint = trim((string) ($module['reason'] ?? ''));
            if ($processHint !== '') {
                $process[] = $processHint;
            }
            $coreTags = array_values((array) ($module['core_tags'] ?? []));
            if (!empty($coreTags)) {
                $process[] = '核心证据：'.implode('、', $coreTags);
            }

            $risks = [];
            if ($risk !== '') {
                $risks[] = $risk;
            }
            $riskLevel = trim((string) ($module['risk_level'] ?? 'low'));
            if ($riskLevel !== '' && $riskLevel !== 'low') {
                $risks[] = '当前风险等级：'.$riskLevel;
            }

            $advice = [];
            $priorityReason = trim((string) ($module['priority_reason'] ?? ''));
            if ($priorityReason !== '' && !str_contains($priorityReason, '常规关注')) {
                $advice[] = '建议优先处理：'.$priorityReason.'。';
            }
            foreach ((array) ($tpl['default_advice'] ?? []) as $line) {
                $line = trim((string) $line);
                if ($line !== '') {
                    $advice[] = $line;
                }
            }

            $out[] = [
                'key' => (string) ($module['key'] ?? ''),
                'label' => $label === '' ? '匹配项' : $label,
                'summary' => $summaryPrefix.$reason,
                'process' => array_values(array_unique(array_filter($process))),
                'risks' => array_values(array_unique(array_filter($risks))),
                'advice' => array_values(array_unique(array_filter($advice))),
                'core_evidence' => $coreTags,
                'supporting_evidence' => array_values((array) ($module['aux_tags'] ?? [])),
                'confidence' => (string) ($module['confidence_tier'] ?? 'low'),
                'priority' => (string) ($module['priority_level'] ?? 'normal'),
            ];
        }
        return $out;
    }
}

