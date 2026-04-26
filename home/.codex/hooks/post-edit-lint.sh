#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat || true)
cwd=$(printf '%s' "$input" | json_get '.cwd')
file_path=$(printf '%s' "$input" | json_get '.tool_input.file_path')
command=$(printf '%s' "$input" | json_get '.tool_input.command')

activate_mise

if [[ -n "$cwd" && -d "$cwd" ]]; then
  cd "$cwd"
fi

files=()
if [[ -n "$file_path" ]]; then
  files+=("$file_path")
fi

if [[ -n "$command" ]]; then
  while IFS= read -r file; do
    [[ -n "$file" ]] && files+=("$file")
  done < <(printf '%s\n' "$command" | sed -nE 's/^\*\*\* (Add|Update) File: (.*)$/\2/p')
fi

if [[ ${#files[@]} -eq 0 ]] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r file; do
    [[ -n "$file" ]] && files+=("$file")
  done < <({
    git diff --name-only 2>/dev/null
    git diff --name-only --cached 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u)
fi

formatted=()
for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.ts|*.tsx|*.js|*.jsx|*.json)
      if [[ "${CODEX_SKIP_BIOME:-}" != "1" ]] && command -v biome >/dev/null 2>&1; then
        biome format --write "$file" >/dev/null 2>&1 || true
        formatted+=("$file")
      fi
      ;;
    *.py)
      if [[ "${CODEX_SKIP_RUFF:-}" != "1" ]] && command -v ruff >/dev/null 2>&1; then
        ruff format "$file" >/dev/null 2>&1 || true
        formatted+=("$file")
      fi
      ;;
    *.md|*.yaml|*.yml|*.scss|*.css)
      if [[ "${CODEX_SKIP_PRETTIER:-}" != "1" ]] && command -v prettier >/dev/null 2>&1; then
        prettier --write "$file" >/dev/null 2>&1 || true
        formatted+=("$file")
      fi
      ;;
  esac
done

if [[ ${#formatted[@]} -gt 0 ]]; then
  printf -v context 'Formatted edited files: %s' "${formatted[*]}"
  hook_context "PostToolUse" "$context"
fi
