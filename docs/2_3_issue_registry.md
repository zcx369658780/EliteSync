# 2.3 Issue Registry

Last Updated: 2026-03-30
Owner: Backend Matching / Astro Pipeline

## P0
1. **Display confidence mismatch**
   - Symptom: UI can present strong confidence wording without explicit engine/data-quality gate.
   - Fix path: `display_guard` config + `ExplanationMetaBuilder`.
   - Status: In progress (2.3-1).

2. **Raw evidence tags exposure risk**
   - Symptom: internal tags may surface in API/UI fallback path.
   - Fix path: `EvidenceTagMapper` + `display_tags` output.
   - Status: In progress (2.3-1).

## P1
3. **Western route expression consistency**
   - Symptom: narrative strength may exceed actual canonical readiness.
   - Fix path: ADR + policy mode + confidence badge guard.
   - Status: Planned (2.3-3).

4. **Explanation stability**
   - Symptom: module explanation structure not fully template-driven/regression-checked.
   - Fix path: template registry + snapshot regression fixtures.
   - Status: Planned (2.3-2).

## P2
5. **Low-sample tuning volatility**
   - Symptom: score calibration can drift with low-volume signals.
   - Fix path: weight-change guard + weekly guardrail report.
   - Status: Planned (2.3-4).

6. **Gray rollout and rollback playbook completeness**
   - Symptom: partial scripts exist but integrated rehearsal checklist is incomplete.
   - Fix path: release checklist + rollback simulation.
   - Status: Planned (2.3-5).
