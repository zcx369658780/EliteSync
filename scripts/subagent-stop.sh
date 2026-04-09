#!/usr/bin/env bash
set -euo pipefail

# SubagentStop hook.
# Finalizes lifecycle logs written by subagent-start.sh.

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
DURATION='unknown'
STARTED_AT=''
START_CWD=''

if [[ -f "$STATE_FILE" ]]; then
  readarray -t META < <(python3 - <<'PY' "$STATE_FILE"
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    data = json.load(f)
print(data.get('started_at', ''))
print(data.get('cwd', ''))
PY
)
  STARTED_AT="${META[0]:-}"
  START_CWD="${META[1]:-}"

  if [[ -n "$STARTED_AT" ]]; then
    DURATION="$(python3 - <<'PY' "$STARTED_AT" "$TS"
from datetime import datetime
import sys
start = datetime.fromisoformat(sys.argv[1])
end = datetime.fromisoformat(sys.argv[2])
print(str(end - start))
PY
)"
  fi
  rm -f "$STATE_FILE"
fi

{
  printf '[%s] subagent stop: %s\n' "$TS" "$AGENT_NAME"
  [[ -n "$START_CWD" ]] && printf '  start cwd: %s\n' "$START_CWD"
  printf '  duration: %s\n' "$DURATION"
} >> "$LOG_FILE"

exit 0
