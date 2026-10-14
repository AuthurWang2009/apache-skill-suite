#!/usr/bin/env bash
# Run the B4 trigger matrix (7 cells) headless against one agent environment.
#
# Usage: ./tests/b4-matrix.sh <zcode|claude|kimi> [cell numbers...]
# Env overrides:
#   KYUUBI_DIR, SEATUNNEL_DIR, FRESH_DIR, NONASF_DIR, NONGIT_DIR
#   CLAUDE_BIN, KIMI_BIN, ZCODE_BIN (default: engine zcode.cjs via node)
#   RUN_TIMEOUT (seconds per cell, default 300)
#
# All cells run in plan/read-only mode: no writes, no pushes.
set -uo pipefail

ENV="${1:?usage: b4-matrix.sh <zcode|claude|kimi> [cells...]}"
shift || true
CELLS=("$@")
[[ ${#CELLS[@]} -eq 0 ]] && CELLS=(1 2 3 4 5 6 7)

KYUUBI_DIR="${KYUUBI_DIR:-$HOME/workspace/projects/opensource/kyuubi}"
SEATUNNEL_DIR="${SEATUNNEL_DIR:-$HOME/workspace/projects/opensource/seatunnel}"
FRESH_DIR="${FRESH_DIR:?FRESH_DIR must point to a fresh ASF clone (cell 5)}"
NONASF_DIR="${NONASF_DIR:-$HOME/workspace/projects/uptunnel.bk}"
NONGIT_DIR="${NONGIT_DIR:-/tmp/b4-nongit}"
RUN_TIMEOUT="${RUN_TIMEOUT:-300}"

CLAUDE_BIN="${CLAUDE_BIN:-claude}"
KIMI_BIN="${KIMI_BIN:-$HOME/.kimi-code/bin/kimi}"
ZCODE_BIN="${ZCODE_BIN:-/Applications/ZCode.app/Contents/Resources/glm/zcode.cjs}"

OUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/tests/out/$ENV/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT_DIR"

run_with_timeout() { # <secs> <cmd...>  (macOS has no `timeout`)
  local secs="$1"; shift
  "$@" &
  local pid=$!
  ( sleep "$secs" && kill -TERM "$pid" 2>/dev/null ) &
  local watchdog=$!
  wait "$pid"; local rc=$?
  kill -TERM "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null
  return $rc
}

run_one() { # <cwd> <prompt> <logfile>
  local cwd="$1" prompt="$2" log="$3" t0 t1 rc
  mkdir -p "$cwd" 2>/dev/null || true
  echo "[$(date +%H:%M:%S)] cwd=$cwd" > "$log"
  echo "prompt=$prompt" >> "$log"
  echo "---" >> "$log"
  t0=$(date +%s)
  case "$ENV" in
    claude)
      run_with_timeout "$RUN_TIMEOUT" bash -c "cd '$cwd' && '$CLAUDE_BIN' -p \"\$0\" --permission-mode plan" "$prompt" >> "$log" 2>&1
      rc=$?
      ;;
    kimi)
      run_with_timeout "$RUN_TIMEOUT" bash -c "cd '$cwd' && '$KIMI_BIN' -p \"\$0\"" "$prompt" >> "$log" 2>&1
      rc=$?
      ;;
    zcode)
      run_with_timeout "$RUN_TIMEOUT" node "$ZCODE_BIN" -p "$prompt" --mode plan --cwd "$cwd" >> "$log" 2>&1
      rc=$?
      ;;
    *) echo "unknown env $ENV" >&2; exit 1 ;;
  esac
  t1=$(date +%s)
  echo "" >> "$log"
  echo "---exit=$rc elapsed=$((t1-t0))s---" >> "$log"
  echo "  cell done rc=$rc $((t1-t0))s -> $log" >&2
}

declare -a DIRS=( "$KYUUBI_DIR" "$KYUUBI_DIR" "$SEATUNNEL_DIR" "$SEATUNNEL_DIR" "$FRESH_DIR" "$NONASF_DIR" "$NONGIT_DIR" )
declare -a PROMPTS=(
  "在 kyuubi 把那个提交一下"
  "同步一下 fork"
  "提交一下"
  "找个 issue 开始做"
  "提交一下"
  "commit this"
  "Apache 项目提 PR 一般怎么走？"
)

for c in "${CELLS[@]}"; do
  idx=$((c-1))
  dir="${DIRS[$idx]}"
  prompt="${PROMPTS[$idx]}"
  if [[ ! -d "$dir" ]]; then
    echo "cell $c: cwd missing: $dir (skipped)" >&2
    continue
  fi
  echo "cell $c: running ($ENV) in $dir ..." >&2
  run_one "$dir" "$prompt" "$OUT_DIR/cell$c.log"
done

echo "All requested cells finished. Logs in $OUT_DIR"
