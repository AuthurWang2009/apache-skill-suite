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
# Install the apache-* skill suite into AI coding agent environments.
#
# Targets:
#   zcode  -> ~/.zcode/skills/<skill>/
#   claude -> ~/.claude/skills/<skill>/
#   kimi   -> ~/.kimi/skills/<skill>/
#
# Usage:
#   ./install.sh                          # auto: every detected environment
#   ./install.sh --target zcode,claude    # explicit subset
#   ./install.sh --symlink                # symlink instead of copy (repo = single source of truth)
#   ./install.sh --with-rules             # also install G-layer rule packs to ~/.zcode/rules/
#                                         # (never overwrites existing packs unless --force)
#   ./install.sh --force                  # allow overwriting existing rule packs
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(apache-commit-pr apache-dev-workflow apache-sync-fork)

TARGETS=""
MODE=copy
WITH_RULES=0
FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)     TARGETS="$2"; shift 2 ;;
    --symlink)    MODE=symlink; shift ;;
    --with-rules) WITH_RULES=1; shift ;;
    --force)      FORCE=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

target_dir() {
  case "$1" in
    zcode)  echo "$HOME/.zcode/skills" ;;
    claude) echo "$HOME/.claude/skills" ;;
    kimi)   echo "${KIMI_CODE_HOME:-$HOME/.kimi-code}/skills" ;;
    *)      return 1 ;;
  esac
}

if [[ -z "$TARGETS" ]]; then
  TARGETS=""
  [[ -d "$HOME/.zcode"  ]] && TARGETS="zcode"
  [[ -d "$HOME/.claude" ]] && TARGETS="${TARGETS:+$TARGETS,}claude"
  [[ -d "${KIMI_CODE_HOME:-$HOME/.kimi-code}" ]] && TARGETS="${TARGETS:+$TARGETS,}kimi"
  if [[ -z "$TARGETS" ]]; then
    echo "No agent environment detected (~/.zcode, ~/.claude, ~/.kimi). Use --target explicitly." >&2
    exit 1
  fi
fi

IFS=',' read -ra TARGET_LIST <<< "$TARGETS"
for target in "${TARGET_LIST[@]}"; do
  dest_parent="$(target_dir "$target")" || { echo "Unknown target: $target" >&2; exit 1; }
  mkdir -p "$dest_parent"
  for skill in "${SKILLS[@]}"; do
    src="$REPO_ROOT/skills/$skill"
    dest="$dest_parent/$skill"
    [[ -d "$src" ]] || { echo "Missing source: $src" >&2; exit 1; }
    if [[ "$MODE" == "symlink" ]]; then
      # keep side-car backups (*.bak*) — they carry the user's migration history
      tmpkeep="$(mktemp -d)"
      find "$dest" -maxdepth 1 -name '*.bak*' -exec mv {} "$tmpkeep/" \; 2>/dev/null || true
      rm -rf "$dest"
      ln -s "$src" "$dest"
      find "$tmpkeep" -maxdepth 1 -name '*.bak*' -exec mv {} "$dest/" \; 2>/dev/null || true
      rmdir "$tmpkeep" 2>/dev/null || true
      echo "[ $target ] symlinked $skill -> $src"
    else
      tmpkeep="$(mktemp -d)"
      find "$dest" -maxdepth 1 -name '*.bak*' -exec mv {} "$tmpkeep/" \; 2>/dev/null || true
      rm -rf "$dest"
      cp -R "$src" "$dest"
      find "$tmpkeep" -maxdepth 1 -name '*.bak*' -exec mv {} "$dest/" \; 2>/dev/null || true
      rmdir "$tmpkeep" 2>/dev/null || true
      echo "[ $target ] copied     $skill"
    fi
  done
done

if [[ "$WITH_RULES" == 1 ]]; then
  mkdir -p "$HOME/.zcode/rules"
  for pack in "$REPO_ROOT"/rules/*.md; do
    name="$(basename "$pack")"
    dest="$HOME/.zcode/rules/$name"
    if [[ -e "$dest" && "$FORCE" != 1 ]]; then
      echo "[ rules ] kept existing $name (use --force to overwrite)"
    else
      cp "$pack" "$dest"
      echo "[ rules ] installed $name -> $dest"
    fi
  done
fi

echo "Done. Skills: ${SKILLS[*]}"
