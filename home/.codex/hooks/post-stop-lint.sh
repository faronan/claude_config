#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat || true)
stop_hook_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)
cwd=$(printf '%s' "$input" | json_get '.cwd')

if [[ "$stop_hook_active" == "true" ]]; then
  stop_continue
  exit 0
fi

activate_mise

if [[ -z "$cwd" || ! -d "$cwd" ]]; then
  stop_continue
  exit 0
fi

cd "$cwd"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  stop_continue
  exit 0
fi

changed_files=$(
  {
    git diff --name-only 2>/dev/null
    git diff --name-only --cached 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u
)

if [[ -z "$changed_files" ]]; then
  stop_continue
  exit 0
fi

if [[ "${CODEX_SKIP_RUFF:-}" != "1" ]] && command -v ruff >/dev/null 2>&1; then
  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    ruff check --fix "$file" >/dev/null 2>&1 || true
    ruff format "$file" >/dev/null 2>&1 || true
  done < <(printf '%s\n' "$changed_files" | grep '\.py$' || true)
fi

if [[ "${CODEX_SKIP_BIOME:-}" != "1" ]] && command -v biome >/dev/null 2>&1; then
  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    biome check --write "$file" >/dev/null 2>&1 || true
  done < <(printf '%s\n' "$changed_files" | grep -E '\.(ts|tsx|js|jsx)$' || true)
fi

if [[ "${CODEX_SKIP_PRETTIER:-}" != "1" ]] && command -v prettier >/dev/null 2>&1; then
  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    prettier --write "$file" >/dev/null 2>&1 || true
  done < <(printf '%s\n' "$changed_files" | grep -E '\.(md|yaml|yml|scss|css)$' || true)
fi

stop_continue
