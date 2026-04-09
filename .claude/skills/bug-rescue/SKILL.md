---
name: bug-rescue
description: Investigate and fix a bug with controlled debugging and low-regression validation.
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash Edit Write
---

Rescue bug: $ARGUMENTS

Workflow:

1. Restate the bug clearly.
2. Identify repro clues, logs, screenshots, and likely modules.
3. Form 2-3 competing hypotheses.
4. If debugging is non-trivial, delegate to `builder-codex`.
5. If screenshots, logs, PDFs, or external docs need interpretation, consult `spec-auditor-gemini`.
6. Implement the smallest safe fix.
7. Run targeted tests or smoke checks.
8. Report:
   - root cause
   - fix
   - verification performed
   - remaining uncertainty
   - whether broader cleanup is recommended

Do not jump to refactor unless the bug cannot be fixed safely otherwise.