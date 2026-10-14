#!/usr/bin/env bash
# Remove the apache-* skill suite from agent environments.
# Only the three explicitly named skill directories are touched (no wildcards,
# so a future apache-* skill added later is never accidentally removed).
set -euo pipefail

SKILLS=(apache-commit-pr apache-dev-workflow apache-sync-fork)
TARGETS="${1:-}"

if [[ -z "$TARGETS" ]]; then
  TARGETS=""
  [[ -d "$HOME/.zcode"  ]] && TARGETS="zcode"
  [[ -d "$HOME/.claude" ]] && TARGETS="${TARGETS:+$TARGETS,}claude"
  [[ -d "${KIMI_CODE_HOME:-$HOME/.kimi-code}" ]] && TARGETS="${TARGETS:+$TARGETS,}kimi"
fi

IFS=',' read -ra TARGET_LIST <<< "$TARGETS"
for target in "${TARGET_LIST[@]}"; do
  case "$target" in
    zcode)  dest_parent="$HOME/.zcode/skills" ;;
    claude) dest_parent="$HOME/.claude/skills" ;;
    kimi)   dest_parent="${KIMI_CODE_HOME:-$HOME/.kimi-code}/skills" ;;
    *) echo "Unknown target: $target" >&2; exit 1 ;;
  esac
  for skill in "${SKILLS[@]}"; do
    dest="$dest_parent/$skill"
    if [[ -L "$dest" || -d "$dest" ]]; then
      rm -rf "$dest"
      echo "[ $target ] removed $skill"
    else
      echo "[ $target ] not present: $skill"
    fi
  done
done
echo "Done."
