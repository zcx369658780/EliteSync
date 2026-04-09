---
name: feature-build
description: Build a new feature with planning, implementation, verification, and review.
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash Edit Write
---

Build feature: $ARGUMENTS

Follow this sequence:

1. Read relevant files first.
2. Summarize the feature in one paragraph.
3. Identify impacted modules.
4. Produce a minimal implementation plan.
5. If the task is substantial, delegate implementation to `builder-codex`.
6. Run targeted verification.
7. For non-trivial changes, request review from `reviewer-codex`.
8. If the feature affects screenshots, copy, onboarding, interaction flow, or spec fidelity, request audit from `spec-auditor-gemini`.
9. Return a final summary with:
   - files changed
   - checks run
   - unresolved risks
   - suggested next step

Do not skip verification.
Do not perform broad refactors unless required.