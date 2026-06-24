#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

mark_fail() {
  printf 'ERROR: %s\n' "$*" >&2
  fail=1
}

require_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    mark_fail "Missing file: $file"
  fi
}

require_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mark_fail "Missing directory: $dir"
  fi
}

require_file "${REPO_ROOT}/home/.cursor/cli-config.json"
require_file "${REPO_ROOT}/home/.cursor/mcp.json"
require_dir "${REPO_ROOT}/home/.cursor/agents"
require_dir "${REPO_ROOT}/home/.agents/skills"
require_dir "${REPO_ROOT}/.cursor/rules"

if command -v jq >/dev/null 2>&1; then
  jq empty "${REPO_ROOT}/home/.cursor/cli-config.json"
  jq empty "${REPO_ROOT}/home/.cursor/mcp.json"
else
  mark_fail "jq is required to validate Cursor JSON config"
fi

while IFS= read -r rule; do
  first_line="$(sed -n '1p' "$rule")"
  if [ "$first_line" != "---" ]; then
    mark_fail "Cursor rule missing opening frontmatter: $rule"
    continue
  fi

  if ! awk 'NR > 1 && $0 == "---" { found=1; exit } END { exit found ? 0 : 1 }' "$rule"; then
    mark_fail "Cursor rule missing closing frontmatter: $rule"
  fi

  if ! rg -q '^(description|globs|alwaysApply):' "$rule"; then
    mark_fail "Cursor rule frontmatter has no activation metadata: $rule"
  fi
done < <(find "${REPO_ROOT}/.cursor/rules" -type f -name '*.mdc' | sort)

while IFS= read -r agent; do
  if ! rg -q '^model: inherit$' "$agent"; then
    mark_fail "Cursor agent must inherit parent model: $agent"
  fi
  if ! rg -q '^readonly: (true|false)$' "$agent"; then
    mark_fail "Cursor agent must declare readonly: $agent"
  fi
done < <(find "${REPO_ROOT}/home/.cursor/agents" -type f -name '*.md' | sort)

if [ "$fail" -ne 0 ]; then
  exit 1
fi

printf 'Cursor config check passed.\n'
