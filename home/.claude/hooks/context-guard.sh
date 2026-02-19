#!/usr/bin/env bash
# PreToolUse フック: 不要ファイルの読み込みをブロック
# Exit codes: 0=許可, 2=ブロック

set -euo pipefail

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# 対象パスを取得（Read: file_path, Glob: pattern）
case "$tool_name" in
  Read)
    target=$(echo "$input" | jq -r '.tool_input.file_path // empty')
    ;;
  Glob)
    target=$(echo "$input" | jq -r '.tool_input.pattern // empty')
    ;;
  *)
    exit 0
    ;;
esac

if [[ -z "$target" ]]; then
  exit 0
fi

# ブロック対象ディレクトリ
blocked_dirs=(
  "node_modules/"
  ".git/"
  "dist/"
  "build/"
  ".next/"
  "__pycache__/"
)

for dir in "${blocked_dirs[@]}"; do
  if [[ "$target" == *"$dir"* ]]; then
    echo "[Guard] Blocked: $target ($dir is not allowed)" >&2
    exit 2
  fi
done

# 大容量ファイル警告（Read のみ、500KB超）
if [[ "$tool_name" == "Read" && -f "$target" ]]; then
  file_size=$(stat -f%z "$target" 2>/dev/null || echo 0)
  if [[ "$file_size" -gt 512000 ]]; then
    size_kb=$((file_size / 1024))
    echo "[Guard] Warning: $target is ${size_kb}KB (>500KB)" >&2
  fi
fi

exit 0
