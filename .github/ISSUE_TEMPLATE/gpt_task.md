---
name: GPT task
about: Task ticket for GPT advisor to hand work to Codex
title: "GPT-TASK: <short title>"
labels: ""
assignees: ""
---

# GPT-TASK: <short title>

Follow `AGENTS.md`. Do not use `git add .` or `git add -A`. Stop on dirty worktree unless dirty-worktree handling is the task. Do not perform high-risk gates unless explicitly authorized. Do not overclaim implementation, verification, production readiness, or final acceptance.

## 0. Task status

Describe whether this is planning-only, documentation-only, tooling-only, runtime, review, or authorization-preparation work.

## 1. Goal

Describe the desired outcome.

## 2. Current baseline

Record expected branch, HEAD, latest commit, and clean/dirty worktree expectation.

## 3. Allowed scope

List the permitted operations.

## 4. Forbidden scope

List prohibited operations, including high-risk gates that are not authorized.

## 5. Read-only references

List repo files or issue/PR links Codex should read before editing.

## 6. Allowed files

List exact files Codex may modify or add.

## 7. Required implementation / documentation content

Describe required content, behavior, or evidence.

## 8. Validation commands

List commands to run. Avoid production, staging, DB, migration, release, or API commands unless explicitly authorized.

## 9. Commit / PR policy

State whether Codex may commit and push directly, open a PR, or stop before commit. Require explicit per-file staging commands.

## 10. Final report format

List the exact final fields Codex should report.

## 11. Next gate

State the next decision or authorization gate. Do not imply that the next high-risk gate is authorized.
