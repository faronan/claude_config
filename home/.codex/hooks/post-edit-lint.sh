#!/usr/bin/env bash
# Codex PostToolUse (Bash) hook: Bash 実行後の差分ファイルを自動フォーマット

input=$(cat) || exit 0
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null) || exit 0

if [[ -z "$cwd" || ! -d "$cwd" ]]; then
  exit 0
fi

cd "$cwd"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
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
  exit 0
fi

if [[ "${CODEX_SKIP_BIOME:-}" != "1" ]] && command -v biome &>/dev/null; then
  js_files=$(echo "$changed_files" | grep -E '\.(ts|tsx|js|jsx|json)$' || true)
  if [[ -n "$js_files" ]]; then
    while IFS= read -r f; do
      [[ -f "$f" ]] && biome format --write "$f" 2>/dev/null || true
    done <<< "$js_files"
  fi
fi

if [[ "${CODEX_SKIP_RUFF:-}" != "1" ]] && command -v ruff &>/dev/null; then
  py_files=$(echo "$changed_files" | grep '\.py$' || true)
  if [[ -n "$py_files" ]]; then
    while IFS= read -r f; do
      [[ -f "$f" ]] && ruff format "$f" 2>/dev/null || true
    done <<< "$py_files"
  fi
fi

if [[ "${CODEX_SKIP_PRETTIER:-}" != "1" ]] && command -v prettier &>/dev/null; then
  style_files=$(echo "$changed_files" | grep -E '\.(md|yaml|yml|scss|css)$' || true)
  if [[ -n "$style_files" ]]; then
    while IFS= read -r f; do
      [[ -f "$f" ]] && prettier --write "$f" 2>/dev/null || true
    done <<< "$style_files"
  fi
fi

exit 0
