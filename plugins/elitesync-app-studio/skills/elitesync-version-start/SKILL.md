# elitesync-version-start

## Purpose

Start a new EliteSync version safely. This skill exists to force a read-only audit before any implementation begins.

## Trigger

- A new version plan is announced.
- A human says "start the version" or "begin implementation".

## Required workflow

0. Confirm this is a version-start flow, not a commit/push flow.
1. Read `docs/DEVELOPMENT_PLAN_CURRENT.md`.
2. Read `docs/project_memory.md`.
3. Read the current handoff entry and the current acceptance status.
4. List the allowed scope, excluded scope, protection surfaces, and verification baseline.
5. Identify the first implementation slice and the files that may be touched.

## Stop condition

- Scope is locked.
- Protection surfaces are named.
- Non-goals are explicit.
- The next action is either implementation or a blocker report.

## Must not do

- Do not edit code.
- Do not stage or commit.
- Do not expand scope to other versions.
