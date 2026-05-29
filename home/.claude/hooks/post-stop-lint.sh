#!/usr/bin/env bash
# Stop フック: タスク完了後の lint auto-fix
# Claude の全編集が完了してから lint を実行し、
# 中間状態での未使用 import 誤削除を防止する
# Exit codes: 0=成功（常に成功）

set -euo pipefail

input=$(cat)

# Stop フックによる再実行時は即座に終了（無限ループ防止）
if [[ "$(echo "$input" | jq -r '.stop_hook_active // false')" == "true" ]]; then
  exit 0
fi

active_task_count=$(echo "$input" | jq '
  ([.background_tasks[]?, .session_crons[]?] |
    map(select(((.status // "") | ascii_downcase) as $s |
      ($s != "completed" and $s != "done" and $s != "failed" and
       $s != "cancelled" and $s != "canceled" and $s != "retired"))) |
    length)
' 2>/dev/null || echo 0)

if [[ "$active_task_count" =~ ^[0-9]+$ && "$active_task_count" -gt 0 ]]; then
  exit 0
fi

cwd=$(echo "$input" | jq -r '.cwd // ""')

if [[ -z "$cwd" || ! -d "$cwd" ]]; then
  exit 0
fi

cd "$cwd"

# git 管理下でない場合はスキップ
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# 変更されたファイルを取得（unstaged + staged + untracked）
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

# Python: ruff check --fix + format
# CLAUDE_SKIP_RUFF=1 でスキップ可能
if [[ "${CLAUDE_SKIP_RUFF:-}" == "1" ]]; then
  : # skip
elif command -v ruff &>/dev/null; then
  py_files=$(echo "$changed_files" | grep '\.py$' || true)
  if [[ -n "$py_files" ]]; then
    while IFS= read -r f; do
      [[ -f "$f" ]] || continue
      ruff check --fix "$f" 2>/dev/null || true
      ruff format "$f" 2>/dev/null || true
    done <<< "$py_files"
  fi
fi

# TypeScript/JavaScript: biome check --write
# CLAUDE_SKIP_BIOME=1 でスキップ可能
if [[ "${CLAUDE_SKIP_BIOME:-}" == "1" ]]; then
  : # skip
elif command -v biome &>/dev/null; then
  js_files=$(echo "$changed_files" | grep -E '\.(ts|tsx|js|jsx)$' || true)
  if [[ -n "$js_files" ]]; then
    while IFS= read -r f; do
      [[ -f "$f" ]] || continue
      biome check --write "$f" 2>/dev/null || true
    done <<< "$js_files"
  fi
fi

# Markdown/YAML/SCSS/CSS: prettier --write
# CLAUDE_SKIP_PRETTIER=1 でスキップ可能
if [[ "${CLAUDE_SKIP_PRETTIER:-}" == "1" ]]; then
  : # skip
elif command -v prettier &>/dev/null; then
  style_files=$(echo "$changed_files" | grep -E '\.(md|yaml|yml|scss|css)$' || true)
  if [[ -n "$style_files" ]]; then
    while IFS= read -r f; do
      [[ -f "$f" ]] || continue
      prettier --write "$f" 2>/dev/null || true
    done <<< "$style_files"
  fi
fi

exit 0
