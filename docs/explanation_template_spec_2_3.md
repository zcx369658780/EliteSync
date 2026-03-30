# Explanation Template Spec 2.3

## Objective
Standardize module explanation output into a stable 4-layer structure, independent from ad-hoc string concatenation.

## Layer Model
Each module should expose:
- `summary`: one-line conclusion
- `process[]`: why this conclusion is formed
- `risks[]`: key risk points / tension signals
- `advice[]`: actionable suggestions

Additional fields:
- `core_evidence[]`
- `supporting_evidence[]`
- `confidence` (`high|medium|low`)
- `priority` (`high|medium|normal`)

## API Placement
Under `match_reasons`:
- existing `module_explanations` stays for compatibility
- new `explanation_blocks` is added as stable template output

## Rules
1. Never output strong deterministic language when confidence is low/degraded.
2. Keep module semantics separated:
   - bazi: long-term rhythm/structure tendency
   - constellation/natal: process layer interaction tendency
   - pair_chart: relationship trajectory tendency
   - mbti: lightweight communication-style hint
3. Advice should be practical and non-mystified.

## Regression
Template output is expected to be snapshot-testable (next step: fixed fixtures + diff script).
