#!/usr/bin/env bash
# PostToolUse フック: 編集後の自動フォーマット
# lint auto-fix は Stop hook (post-stop-lint.sh) で実行し、
# 中間編集での未使用 import 誤削除を防止する
# Exit codes: 0=成功（警告のみ）

# Claude CodeからのJSON入力を読み取り
input=$(cat) || exit 0

# tool_inputからファイルパスを取得（Edit/Write共通）
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0

if [[ -z "$file_path" ]]; then
  exit 0
fi

# ファイルが存在しない場合はスキップ
if [[ ! -f "$file_path" ]]; then
  exit 0
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

    # console.log 警告（JS/TSのみ）
    if [[ "$extension" =~ ^(ts|tsx|js|jsx)$ ]]; then
      if grep -n "console\.log" "$file_path" 2>/dev/null; then
        echo "[Warning] console.log found in $file_path - consider removing before commit" >&2
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

    # print() 警告
    if grep -n "^[^#]*print(" "$file_path" 2>/dev/null | grep -v "# noqa"; then
      echo "[Warning] print() found in $file_path - consider removing before commit" >&2
    fi
    ;;

  md|yaml|yml|scss|css)
    if command -v prettier &> /dev/null; then
      result=$(prettier --write "$file_path" 2>&1) || {
        echo "[Format] Prettier auto-formatted $file_path:" >&2
        echo "$result" >&2
      }
    fi
    ;;
esac

# 常に成功（警告表示のみ、ブロックはしない）
exit 0
