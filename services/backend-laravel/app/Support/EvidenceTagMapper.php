<?php

namespace App\Support;

class EvidenceTagMapper
{
    /**
     * @param array<string,mixed>|null $dictionary
     */
    public function __construct(private readonly ?array $dictionary = null)
    {
    }

    /**
     * @param array<int,mixed> $tags
     * @return list<string>
     */
    public function normalizeTags(array $tags): array
    {
        $out = [];
        foreach ($tags as $tag) {
            $value = strtolower(trim((string) $tag));
            if ($value === '') {
                continue;
            }
            $out[] = $value;
        }
        return array_values(array_unique($out));
    }

    public function label(string $tag): string
    {
        $key = strtolower(trim($tag));
        if ($key === '') {
            return '';
        }
        $dict = $this->dictionary ?? (array) config('match_evidence_tags', []);
        $meta = (array) ($dict[$key] ?? []);
        $label = trim((string) ($meta['label'] ?? ''));
        return $label !== '' ? $label : $tag;
    }

    /**
     * @param array<int,mixed> $tags
     * @return list<string>
     */
    public function toDisplayLabels(array $tags): array
    {
        $normalized = $this->normalizeTags($tags);
        $labels = [];
        foreach ($normalized as $tag) {
            $label = $this->label($tag);
            if ($label !== '') {
                $labels[] = $label;
            }
        }
        return array_values(array_unique($labels));
    }
}

