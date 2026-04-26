#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat || true)
cwd=$(printf '%s' "$input" | json_get '.cwd')

activate_mise

context_lines=()

missing=()
for cmd in biome prettier ruff; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if [[ ${#missing[@]} -gt 0 ]]; then
  context_lines+=("[Session] Missing tools: ${missing[*]}")
fi

if [[ -n "$cwd" && -d "$cwd" ]]; then
  cd "$cwd"
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null || echo "detached")
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  context_lines+=("[Session] Git: $branch (uncommitted: $dirty)")
fi

node_ver=$(node --version 2>/dev/null || echo "not found")
python_ver=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "not found")
context_lines+=("[Session] Node: $node_ver / Python: $python_ver")

printf -v context '%s\n' "${context_lines[@]}"
hook_context "SessionStart" "$context"
