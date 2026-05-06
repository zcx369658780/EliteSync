# elitesync-dirty-worktree

## Purpose

Clean and organize a dirty EliteSync worktree one theme at a time.

## Trigger

- `git status --short` is non-empty.
- The repository needs to be prepared for a single-theme commit or archive action.

## Required workflow

1. Inspect `git status --short`, `git diff --stat`, and `git diff --name-only`.
2. Bucket all dirty files into A / B / C / D.
3. Pick only one theme for the next commit.
4. Stage only the confirmed files for that theme.
5. Before commit, output the staged file list, excluded files, and proposed commit message.
6. Wait for human confirmation before committing.

## Stop condition

- One theme is staged and confirmed.
- The remaining dirty work is clearly classified.

## Must not do

- Do not run `git add .`.
- Do not do repo-wide restore/reset/clean.
- Do not use git stash.
- Do not delete tracked files as a shortcut.
- Do not mix multiple themes into one commit.
