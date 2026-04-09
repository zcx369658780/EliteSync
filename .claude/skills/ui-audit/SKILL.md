---
name: ui-audit
description: Audit UI implementation against screenshots, product requirements, and user-facing flow expectations.
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash
---

Audit UI: $ARGUMENTS

Your audit must cover:

1. screen purpose
2. layout consistency
3. visual hierarchy
4. wording clarity
5. missing states
6. interaction flow continuity
7. mismatch between product intent and implementation

If screenshots or design references are available, compare against them explicitly.
If implementation details are needed, read relevant frontend files.
If a likely code cause is found, point to the specific file or component.

Return:
- confirmed issues
- likely causes
- severity
- concrete fix suggestions