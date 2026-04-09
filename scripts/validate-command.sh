#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook for Bash.
# Purpose:
#   - block obviously destructive commands
#   - warn on commands with higher release / data-loss risk
#   - keep an audit trail for debugging agent behavior

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOG_DIR="$ROOT/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/validate-command.log"

extract_command_from_json() {
  python3 - <<'PY'
import json, sys
raw = sys.stdin.read().strip()
if not raw:
    print("")
    raise SystemExit(0)
try:
    data = json.loads(raw)
except Exception:
    print("")
    raise SystemExit(0)

candidates = []
for key in ("tool_input", "input", "command"):
    value = data.get(key)
    if isinstance(value, str) and value.strip():
        candidates.append(value)
    elif isinstance(value, dict):
        for subkey in ("command", "cmd", "input"):
            subvalue = value.get(subkey)
            if isinstance(subvalue, str) and subvalue.strip():
                candidates.append(subvalue)

print(candidates[0] if candidates else "")
PY
}

COMMAND_INPUT="${1-}"
if [[ -z "$COMMAND_INPUT" && ! -t 0 ]]; then
  COMMAND_INPUT="$(cat | extract_command_from_json || true)"
fi

if [[ -z "$COMMAND_INPUT" ]]; then
  exit 0
fi

LOWER_CMD="$(printf '%s' "$COMMAND_INPUT" | tr '[:upper:]' '[:lower:]')"
TS="$(date '+%F %T')"

log_line() {
  printf '[%s] %s\n' "$TS" "$1" >> "$LOG_FILE"
}

block() {
  log_line "BLOCK: $1 :: $COMMAND_INPUT"
  printf '[hook:block] %s\n' "$1" >&2
  printf '[hook:block] command: %s\n' "$COMMAND_INPUT" >&2
  exit 2
}

warn() {
  log_line "WARN: $1 :: $COMMAND_INPUT"
  printf '[hook:warn] %s\n' "$1" >&2
}

log_line "CHECK: $COMMAND_INPUT"

# Hard blocks: destructive / dangerous commands.
[[ "$LOWER_CMD" =~ (^|[[:space:]])rm[[:space:]]+-rf[[:space:]]+/($|[[:space:]]) ]] && block 'Refusing destructive root deletion.'
[[ "$LOWER_CMD" =~ (^|[[:space:]])sudo[[:space:]]+rm[[:space:]]+-rf ]] && block 'Refusing privileged recursive deletion.'
[[ "$LOWER_CMD" =~ (^|[[:space:]])(mkfs|fdisk|diskpart|format|reboot|shutdown|halt|poweroff)($|[[:space:]]) ]] && block 'Refusing destructive system-level command.'
[[ "$LOWER_CMD" =~ dd[[:space:]].*of=/dev/ ]] && block 'Refusing raw disk write command.'
[[ "$LOWER_CMD" =~ chmod[[:space:]]+-r?[[:space:]]+777[[:space:]]+/ ]] && block 'Refusing broad permission change near filesystem root.'
[[ "$LOWER_CMD" =~ :[[:space:]]*>[[:space:]]*/etc/ ]] && block 'Refusing overwrite of system configuration under /etc.'

# Guardrails for risky repository-destructive commands.
if [[ "$LOWER_CMD" =~ git[[:space:]]+reset[[:space:]]+--hard ]] || \
   [[ "$LOWER_CMD" =~ git[[:space:]]+clean[[:space:]]+-fdx ]] || \
   [[ "$LOWER_CMD" =~ git[[:space:]]+checkout[[:space:]]+--[[:space:]] ]]; then
  [[ "${ALLOW_DESTRUCTIVE_GIT:-0}" == "1" ]] || block 'Refusing destructive git cleanup. Set ALLOW_DESTRUCTIVE_GIT=1 if explicitly intended.'
fi

# Guardrails for remote shell execution.
if [[ "$LOWER_CMD" =~ (curl|wget).*(\||\>).*(bash|sh|zsh) ]] || \
   [[ "$LOWER_CMD" =~ invoke-webrequest.*iex ]] || \
   [[ "$LOWER_CMD" =~ irm[[:space:]].*\|[[:space:]]*iex ]]; then
  [[ "${ALLOW_REMOTE_EXEC:-0}" == "1" ]] || block 'Refusing remote script execution. Set ALLOW_REMOTE_EXEC=1 if explicitly intended.'
fi

# Soft warnings only.
[[ "$LOWER_CMD" =~ npm[[:space:]]+publish ]] && warn 'npm publish detected.'
[[ "$LOWER_CMD" =~ git[[:space:]]+push ]] && warn 'git push detected.'
[[ "$LOWER_CMD" =~ (scp|rsync|sftp) ]] && warn 'File transfer command detected.'
[[ "$LOWER_CMD" =~ docker[[:space:]]+system[[:space:]]+prune ]] && warn 'Docker prune detected.'
[[ "$LOWER_CMD" =~ (pnpm|npm|yarn|bun)[[:space:]]+install ]] && warn 'Dependency install detected; verify lockfile impact.'

log_line "ALLOW: $COMMAND_INPUT"
exit 0
