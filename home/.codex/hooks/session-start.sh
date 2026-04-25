#!/usr/bin/env bash
# Codex SessionStart hook: 環境チェック

missing=()
for cmd in biome prettier; do
  command -v "$cmd" &> /dev/null || missing+=("$cmd")
done
command -v ruff &> /dev/null || missing+=("ruff")

if [ ${#missing[@]} -gt 0 ]; then
  echo "[Session] Missing tools: ${missing[*]}"
fi

if git rev-parse --is-inside-work-tree &> /dev/null; then
  branch=$(git branch --show-current 2>/dev/null || echo "detached")
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "[Session] Git: $branch (uncommitted: $dirty)"
fi

node_ver=$(node --version 2>/dev/null || echo "not found")
python_ver=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "not found")
echo "[Session] Node: $node_ver / Python: $python_ver"

exit 0
