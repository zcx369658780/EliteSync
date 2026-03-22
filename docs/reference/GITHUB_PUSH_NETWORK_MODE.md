# GitHub Push Network Mode (Verified)

## Verified working mode on 2026-03-12
- VPN client: Clash for Windows (running).
- Push path: GitHub HTTPS with local proxy.
- Effective environment:
  - `HTTP_PROXY=http://127.0.0.1:7890`
  - `HTTPS_PROXY=http://127.0.0.1:7890`

## Where to store local push config
- External (outside repo): `C:\Users\zcxve\.codex\memories\secrets\elitesync_github_push.env`

## Required keys in external config
- `GITHUB_REPO_URL`
- `GIT_BRANCH`
- `GIT_USER_NAME`
- `GIT_USER_EMAIL`
- `GITHUB_TOKEN` (optional if credential manager is used)

## Optional network keys in external config
- `HTTP_PROXY`
- `HTTPS_PROXY`

## Example snippet
```env
GITHUB_REPO_URL=https://github.com/zcx369658780/EliteSync.git
GIT_BRANCH=phase-a-2026-03-12
GIT_USER_NAME=your-name
GIT_USER_EMAIL=you@example.com
GITHUB_TOKEN=***
HTTP_PROXY=http://127.0.0.1:7890
HTTPS_PROXY=http://127.0.0.1:7890
```

## Usage
```powershell
cd D:\EliteSync
powershell -ExecutionPolicy Bypass -File .\scripts\publish_to_github.ps1 -CommitMessage "chore: day-end progress"
```
