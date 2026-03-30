# Confidence Badge Rules 2.3

## Goal
Unify backend engine state, data quality, confidence and UI badge issuance to prevent overstatement.

## Rule Set
### 1) High Confidence Badge (`allow_high_confidence_badge`)
Must satisfy all:
- `engine_mode` in allowed modes (default: `canonical`)
- not in denied modes (`legacy`, `fallback`, `hybrid`)
- `precision_level` not in denied levels (`low`, `estimated`)
- `data_quality` not in denied levels (`date_only`, `partial_unknown`)
- confidence >= `display_guard.confidence.high_threshold`
- not degraded

### 2) Strong Evidence Badge (`allow_strong_evidence_badge`)
Must satisfy all high-confidence preconditions plus:
- confidence >= `display_guard.confidence.strong_evidence_threshold`
- core evidence count >= `display_guard.evidence.core_min_count`

### 3) Precise Wording (`allow_precise_wording`)
Must satisfy:
- canonical mode and not degraded
- precision not estimated/low
- confidence >= `display_guard.confidence.precise_wording_threshold`

## Output Contract
Each module should expose:
- `engine_source`
- `engine_mode`
- `data_quality`
- `precision_level`
- `confidence_tier`
- `confidence_reason[]`
- `display_guard`

## Notes
- This rule only controls display strength; ranking score logic remains in matching engine.
- Raw evidence tags are retained for audit/debug, while UI should use mapped `display_tags`.
