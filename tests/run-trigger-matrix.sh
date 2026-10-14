#!/usr/bin/env bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Run the 7-cell trigger matrix (see docs/b4-matrix.md) headless against one
# agent environment, in plan/read-only mode where the CLI supports it.
#
# Usage: ./tests/run-trigger-matrix.sh <zcode|claude|kimi> [cell numbers...]
#
# All paths are anchored at the repository root (resolved from this script's
# location), so the harness works from any cwd. Environment overrides:
#
#   KYUUBI_DIR     default ../opensource/kyuubi     (cell 1-2 workspace)
#   SEATUNNEL_DIR  default ../opensource/seatunnel  (cell 3-4 workspace)
#   FRESH_DIR      default .work/fresh-pulsar       (cell 5; shallow-cloned
#                                                   automatically when missing)
#   NONASF_DIR     default ../uptunnel.bk           (cell 6 workspace)
#   NONGIT_DIR     default tests/fixtures/plain-dir (cell 7; created if missing)
#   CLAUDE_BIN     default claude   (resolved via PATH)
#   KIMI_BIN       default kimi     (resolved via PATH)
#   ZCODE_BIN      default zcode    (resolved via PATH; on macOS desktop
#                  installs point it at
#                  /Applications/ZCode.app/Contents/Resources/glm/zcode.cjs)
#   RUN_TIMEOUT    seconds per cell, default 300
#
# All cells run in plan/read-only mode: no writes, no pushes.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ENV="${1:?usage: run-trigger-matrix.sh <zcode|claude|kimi> [cells...]}"
shift || true
CELLS=("$@")
[[ ${#CELLS[@]} -eq 0 ]] && CELLS=(1 2 3 4 5 6 7)

KYUUBI_DIR="${KYUUBI_DIR:-$REPO_ROOT/../opensource/kyuubi}"
SEATUNNEL_DIR="${SEATUNNEL_DIR:-$REPO_ROOT/../opensource/seatunnel}"
FRESH_DIR="${FRESH_DIR:-$REPO_ROOT/.work/fresh-pulsar}"
NONASF_DIR="${NONASF_DIR:-$REPO_ROOT/../uptunnel.bk}"
NONGIT_DIR="${NONGIT_DIR:-$REPO_ROOT/tests/fixtures/plain-dir}"
RUN_TIMEOUT="${RUN_TIMEOUT:-300}"

CLAUDE_BIN="${CLAUDE_BIN:-claude}"
KIMI_BIN="${KIMI_BIN:-kimi}"
ZCODE_BIN="${ZCODE_BIN:-zcode}"

OUT_DIR="$REPO_ROOT/tests/out/$ENV/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT_DIR"

kill_tree() { # <pid> — TERM a pid and all its descendants
  local p="$1" c
  for c in $(pgrep -P "$p" 2>/dev/null); do kill_tree "$c"; done
  kill -TERM "$p" 2>/dev/null
}

run_with_timeout() { # <secs> <cmd...>  (macOS has no `timeout`)
  local secs="$1"; shift
  "$@" &
  local pid=$!
  ( sleep "$secs" && kill_tree "$pid" ) &
  local watchdog=$!
  wait "$pid"; local rc=$?
  kill -TERM "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null
  # belt and braces: ensure the whole child tree is gone even on normal exit
  kill_tree "$pid"
  return $rc
}

prepare_fixtures() {
  # cell 5: fresh clone of a third ASF repo (shallow, disposable, gitignored)
  if [[ " ${CELLS[*]} " == *" 5 "* ]] && [[ ! -d "$FRESH_DIR/.git" ]]; then
    echo "cell 5: fresh clone missing, shallow-cloning apache/pulsar -> $FRESH_DIR" >&2
    git clone --depth 50 --single-branch https://github.com/apache/pulsar.git "$FRESH_DIR" >&2 || true
  fi
  # cell 7: a plain non-git directory
  if [[ " ${CELLS[*]} " == *" 7 "* ]] && [[ ! -d "$NONGIT_DIR" ]]; then
    mkdir -p "$NONGIT_DIR"
    echo "plain fixture directory, not a git repository" > "$NONGIT_DIR/README.txt"
  fi
}

run_one() { # <cwd> <prompt> <logfile>
  local cwd="$1" prompt="$2" log="$3" t0 t1 rc
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
      if [[ "$ZCODE_BIN" == *.cjs ]]; then
        run_with_timeout "$RUN_TIMEOUT" node "$ZCODE_BIN" -p "$prompt" --mode plan --cwd "$cwd" >> "$log" 2>&1
      else
        run_with_timeout "$RUN_TIMEOUT" "$ZCODE_BIN" -p "$prompt" --mode plan --cwd "$cwd" >> "$log" 2>&1
      fi
      rc=$?
      ;;
    *) echo "unknown env $ENV" >&2; exit 1 ;;
  esac
  t1=$(date +%s)
  echo "" >> "$log"
  echo "---exit=$rc elapsed=$((t1-t0))s---" >> "$log"
  echo "  cell done rc=$rc $((t1-t0))s -> $log" >&2
}

prepare_fixtures

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
