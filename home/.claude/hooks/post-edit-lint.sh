#!/usr/bin/env bash
# PostToolUse フック: 編集後の自動フォーマット
# lint auto-fix は Stop hook (post-stop-lint.sh) で実行し、
# 中間編集での未使用 import 誤削除を防止する
#
# 警告は additionalContext で Claude に返し、次ターンで自発修正を促す。
# フォーマット結果や I/O ノイズは stderr に出してユーザーにのみ表示する。
# Exit codes: 0=成功（警告のみ）

# Claude CodeからのJSON入力を読み取り
input=$(cat) || exit 0

# tool_inputからファイルパスを取得（Edit/Write共通）
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
duration_ms=$(echo "$input" | jq -r '.duration_ms // 0' 2>/dev/null) || duration_ms=0

if [[ -z "$file_path" ]]; then
  exit 0
fi

# ファイルが存在しない場合はスキップ
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Claude に渡す警告を蓄積する配列
warnings=()

# 30秒超の書き込みは異常（大容量ファイルの可能性）
if (( duration_ms > 30000 )); then
  warnings+=("Slow write: ${duration_ms}ms for $file_path (file may be too large to handle in a single edit)")
fi

extension="${file_path##*.}"

case "$extension" in
  ts|tsx|js|jsx|json)
    # Biome format のみ（lint auto-fix は Stop hook で実行）
    # CLAUDE_SKIP_BIOME=1 でスキップ可能
    if [[ "${CLAUDE_SKIP_BIOME:-}" == "1" ]]; then
      : # skip
    elif command -v biome &> /dev/null; then
      result=$(biome format --write "$file_path" 2>&1) || {
        echo "[Format] Biome auto-formatted $file_path:" >&2
        echo "$result" >&2
      }
    fi

    # console.log 警告（JS/TSのみ、新規追加行のみ）
    if [[ "$extension" =~ ^(ts|tsx|js|jsx)$ ]]; then
      added_console=$(git diff --no-color -U0 -- "$file_path" 2>/dev/null | grep -E '^\+[^+]' | grep -F 'console.log' || true)
      if [[ -n "$added_console" ]]; then
        warnings+=("New console.log added in $file_path. Remove before commit unless intentional:\n$added_console")
      fi
    fi
    ;;

  py)
    # Ruff format のみ（lint auto-fix は Stop hook で実行）
    # CLAUDE_SKIP_RUFF=1 でスキップ可能
    if [[ "${CLAUDE_SKIP_RUFF:-}" == "1" ]]; then
      : # skip
    elif command -v ruff &> /dev/null; then
      format_result=$(ruff format "$file_path" 2>&1) || {
        echo "[Format] Ruff auto-formatted $file_path:" >&2
        echo "$format_result" >&2
      }
    fi

    # print() 警告（新規追加行のみ）
    added_print=$(git diff --no-color -U0 -- "$file_path" 2>/dev/null | grep -E '^\+[^+]' | grep -E 'print\(' | grep -v '# noqa' || true)
    if [[ -n "$added_print" ]]; then
      warnings+=("New print() added in $file_path. Remove before commit unless intentional:\n$added_print")
    fi
    ;;

  md|yaml|yml|scss|css)
    # CLAUDE_SKIP_PRETTIER=1 でスキップ可能
    if [[ "${CLAUDE_SKIP_PRETTIER:-}" == "1" ]]; then
      : # skip
    elif command -v prettier &> /dev/null; then
      result=$(prettier --write "$file_path" 2>&1) || {
        echo "[Format] Prettier auto-formatted $file_path:" >&2
        echo "$result" >&2
      }
    fi
    ;;
esac

# 警告がある場合は additionalContext として返す
# Claude が次ターンで自発的に修正できるよう、事実ベースで列挙する
if (( ${#warnings[@]} > 0 )); then
  context=$(printf '%s\n\n' "${warnings[@]}")
  jq -n --arg ctx "$context" '{
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": $ctx
    }
  }'
fi

exit 0
