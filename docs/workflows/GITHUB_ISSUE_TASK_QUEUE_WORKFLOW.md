# GitHub Issue Task Queue Workflow

## 0. One-line conclusion

- GitHub Issues are the task queue between GPT advisor and Codex.
- Repo docs remain the canonical project source.
- User only forwards an issue number or confirms high-risk gates.

## 1. Roles

- GPT advisor creates or reviews issues.
- User authorizes high-risk gates and tells Codex the issue number.
- Codex reads AGENTS.md and the issue body, executes allowed scope, commits/pushes or opens PR only if authorized.
- GitHub stores task history, diffs, comments, and review decisions.

## 2. Standard task flow

1. GPT advisor creates issue titled `GPT-TASK: ...`.
2. Issue body contains goal, baseline, allowed files, forbidden scope, validation, commit/push policy, final report format.
3. User tells Codex: `Please read and execute GitHub issue #<n>, following AGENTS.md.`
4. Codex fetches the issue with GitHub CLI or a repo-approved script.
5. Codex executes only allowed scope.
6. Codex reports commit hash / PR link.
7. GPT advisor reviews commit / PR directly through GitHub.

## 3. High-risk gate policy

- SSH write operation, symlink creation, nginx -t, reload, endpoint verification, staging/production request, DB/migration/restore, release chain changes must be separately authorized.
- A GitHub issue may prepare an authorization package, but cannot silently authorize the next gate unless the user explicitly confirms.

## 4. Issue label / title conventions

- title prefix: `GPT-TASK:`
- optional labels: `gpt-task`, `docs-only`, `authorization-required`, `server-gate`, `runtime`, `review-needed`
- if labels do not exist, task execution must not fail; labels are optional.

## 5. Codex issue-reading command examples

```powershell
gh issue view <number> --json number,title,body,labels,state,url
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts/codex_read_github_issue_task.ps1 -IssueNumber <number>
```

## 6. Stop conditions

- issue is missing / closed / ambiguous
- baseline mismatch
- dirty worktree
- task body conflicts with AGENTS.md
- allowed files unclear
- high-risk action requested without explicit user authorization
- gh CLI unauthenticated or repository mismatch

## 7. Final report format

- issue number
- branch / HEAD
- changed files
- commit hash / PR link
- what was not done
- safety confirmations
- next gate
