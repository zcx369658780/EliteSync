#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook for Edit/Write.
# Runs the smallest meaningful checks first and logs explicit skip reasons.
# Preferred order for Node/web repos:
#   1) typecheck
#   2) lint
#   3) targeted test (only if a lightweight script exists)

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

LOG_DIR="$ROOT/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/post-edit-checks.log"
TS="$(date '+%F %T')"

log() {
  printf '[%s] %s\n' "$TS" "$1" | tee -a "$LOG_FILE"
}

# Collect changed files from staged + unstaged diffs.
mapfile -t CHANGED_FILES < <(
  {
    git diff --name-only -- . 2>/dev/null || true
    git diff --cached --name-only -- . 2>/dev/null || true
  } | sed '/^$/d' | sort -u
)

if [[ ${#CHANGED_FILES[@]} -eq 0 ]]; then
  log 'skip: no changed files detected.'
  exit 0
fi

log 'post-edit checks started.'
for f in "${CHANGED_FILES[@]}"; do
  log "changed: $f"
done

has_ext() {
  local regex="$1"
  printf '%s\n' "${CHANGED_FILES[@]}" | grep -Eq "$regex"
}

has_pkg_script() {
  local script_name="$1"
  [[ -f package.json ]] || return 1
  python3 - "$script_name" <<'PY'
import json, sys
script = sys.argv[1]
with open('package.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
print('1' if script in data.get('scripts', {}) else '0')
PY
}

run_and_log() {
  local label="$1"
  shift
  log "run: $label :: $*"
  "$@" 2>&1 | tee -a "$LOG_FILE"
}

pm_run() {
  local script_name="$1"
  case "$PM" in
    pnpm) pnpm -s "$script_name" ;;
    yarn) yarn -s "$script_name" ;;
    npm)  npm run -s "$script_name" ;;
    bun)  bun run "$script_name" ;;
    *) return 1 ;;
  esac
}

PM=""
if [[ -f pnpm-lock.yaml ]]; then
  PM="pnpm"
elif [[ -f yarn.lock ]]; then
  PM="yarn"
elif [[ -f bun.lockb || -f bun.lock ]]; then
  PM="bun"
elif [[ -f package-lock.json || -f package.json ]]; then
  PM="npm"
fi

FAILED=0
NODE_REPO=false
if [[ -f package.json ]]; then
  NODE_REPO=true
  log "repo: node package detected; package manager=${PM:-unknown}"
else
  log 'repo: no package.json found; node checks may be skipped.'
fi

if [[ "$NODE_REPO" == true ]] && has_ext '\.(ts|tsx)$'; then
  if [[ "$(has_pkg_script typecheck || true)" == "1" ]]; then
    run_and_log 'typecheck' pm_run typecheck || FAILED=1
  else
    log 'skip: ts/tsx changed but no package script named typecheck.'
  fi
else
  has_ext '\.(ts|tsx)$' || log 'skip: no ts/tsx files changed.'
fi

if [[ "$NODE_REPO" == true ]] && has_ext '\.(js|jsx|ts|tsx)$'; then
  if [[ "$(has_pkg_script lint || true)" == "1" ]]; then
    run_and_log 'lint' pm_run lint || FAILED=1
  else
    log 'skip: js/ts files changed but no package script named lint.'
  fi
else
  has_ext '\.(js|jsx|ts|tsx)$' || log 'skip: no js/jsx/ts/tsx files changed.'
fi

if [[ "$NODE_REPO" == true ]] && has_ext '\.(js|jsx|ts|tsx)$'; then
  TEST_SCRIPT=""
  for candidate in test:changed test:quick test:unit test; do
    if [[ "$(has_pkg_script "$candidate" || true)" == "1" ]]; then
      TEST_SCRIPT="$candidate"
      break
    fi
  done
  if [[ -n "$TEST_SCRIPT" ]]; then
    if [[ "$TEST_SCRIPT" == "test" ]]; then
      log 'skip: only full test script found; avoiding expensive repo-wide test from post-edit hook.'
    else
      run_and_log "$TEST_SCRIPT" pm_run "$TEST_SCRIPT" || FAILED=1
    fi
  else
    log 'skip: no targeted test script found (looked for test:changed, test:quick, test:unit, test).'
  fi
fi

if [[ -f Cargo.toml ]]; then
  if has_ext '\.rs$'; then
    if command -v cargo >/dev/null 2>&1; then
      run_and_log 'cargo check' cargo check -q || FAILED=1
    else
      log 'skip: rust files changed but cargo not found.'
    fi
  else
    log 'skip: Cargo.toml exists but no Rust files changed.'
  fi
else
  log 'skip: no Cargo.toml found.'
fi

if [[ -f pyproject.toml || -f requirements.txt ]]; then
  if has_ext '\.py$'; then
    if command -v python3 >/dev/null 2>&1; then
      PY_FILES=()
      for f in "${CHANGED_FILES[@]}"; do
        [[ "$f" == *.py ]] && [[ -f "$f" ]] && PY_FILES+=("$f")
      done
      if [[ ${#PY_FILES[@]} -gt 0 ]]; then
        run_and_log 'python compile' python3 -m py_compile "${PY_FILES[@]}" || FAILED=1
      else
        log 'skip: python files were reported changed, but none exist on disk now.'
      fi
    else
      log 'skip: python files changed but python3 not found.'
    fi
  else
    log 'skip: python project markers found but no .py files changed.'
  fi
else
  log 'skip: no Python project markers found.'
fi

if [[ $FAILED -ne 0 ]]; then
  log "error: one or more post-edit checks failed. See $LOG_FILE"
  exit 2
fi

log 'post-edit checks completed successfully.'
exit 0
