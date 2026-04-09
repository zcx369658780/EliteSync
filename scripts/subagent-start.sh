#!/usr/bin/env bash
set -euo pipefail

# SubagentStart hook.
# Records lifecycle + environment info for debugging multi-agent workflows.
# This hook does not invoke Codex or Gemini; it only checks whether those CLIs are available.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
RUNTIME_DIR="$ROOT/.claude/runtime"
LOG_DIR="$ROOT/.claude/logs"
mkdir -p "$RUNTIME_DIR" "$LOG_DIR"
LOG_FILE="$LOG_DIR/subagent-events.log"

read_json() {
  python3 - <<'PY'
import json, sys
raw = sys.stdin.read().strip()
if not raw:
    print('{}')
    raise SystemExit(0)
try:
    data = json.loads(raw)
except Exception:
    print('{}')
    raise SystemExit(0)
print(json.dumps(data, ensure_ascii=False))
PY
}

PAYLOAD='{}'
if [[ ! -t 0 ]]; then
  PAYLOAD="$(cat | read_json || printf '{}')"
fi

AGENT_NAME="$(python3 - <<'PY' "$PAYLOAD"
import json, sys
payload = json.loads(sys.argv[1])
for key in ('subagent_name', 'agent_name', 'matcher', 'hook_event_name'):
    value = payload.get(key)
    if isinstance(value, str) and value:
        print(value)
        raise SystemExit(0)
print('unknown-subagent')
PY
)"

STATE_FILE="$RUNTIME_DIR/${AGENT_NAME}.json"
TS="$(date -Iseconds)"
CWD="$(pwd)"
CODEX_PATH="$(command -v codex 2>/dev/null || true)"
GEMINI_PATH="$(command -v gemini 2>/dev/null || true)"
CODEX_OK=false
GEMINI_OK=false
[[ -n "$CODEX_PATH" ]] && CODEX_OK=true
[[ -n "$GEMINI_PATH" ]] && GEMINI_OK=true

cat > "$STATE_FILE" <<JSON
{
  "agent": "$AGENT_NAME",
  "started_at": "$TS",
  "cwd": "$CWD",
  "repo_root": "$ROOT",
  "codex_available": $CODEX_OK,
  "codex_path": "${CODEX_PATH:-}",
  "gemini_available": $GEMINI_OK,
  "gemini_path": "${GEMINI_PATH:-}",
  "shell_pid": $$
}
JSON

{
  printf '[%s] subagent start: %s\n' "$TS" "$AGENT_NAME"
  printf '  cwd: %s\n' "$CWD"
  printf '  repo_root: %s\n' "$ROOT"
  printf '  codex available: %s\n' "$CODEX_OK"
  [[ -n "$CODEX_PATH" ]] && printf '  codex path: %s\n' "$CODEX_PATH"
  printf '  gemini available: %s\n' "$GEMINI_OK"
  [[ -n "$GEMINI_PATH" ]] && printf '  gemini path: %s\n' "$GEMINI_PATH"
} >> "$LOG_FILE"

if [[ "$AGENT_NAME" == *codex* ]] && [[ "$CODEX_OK" != true ]]; then
  printf '[hook:warn] codex CLI not found for subagent %s\n' "$AGENT_NAME" >&2
fi
if [[ "$AGENT_NAME" == *gemini* ]] && [[ "$GEMINI_OK" != true ]]; then
  printf '[hook:warn] gemini CLI not found for subagent %s\n' "$AGENT_NAME" >&2
fi

exit 0
