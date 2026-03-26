#!/usr/bin/env bash
# PreToolUse フック: 不要ファイルの読み込みをブロック

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat) || pretooluse_allow

tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null) || pretooluse_allow

# 対象パスを取得（Read: file_path, Glob: pattern）
case "$tool_name" in
  Read)
    target=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || pretooluse_allow
    ;;
  Glob)
    target=$(echo "$input" | jq -r '.tool_input.pattern // empty' 2>/dev/null) || pretooluse_allow
    ;;
  *)
    pretooluse_allow
    ;;
esac

if [[ -z "$target" ]]; then
  pretooluse_allow
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
    pretooluse_deny "[Guard] Blocked: $target ($dir is not allowed)"
  fi
done

# 大容量ファイル警告（Read のみ、500KB超）
if [[ "$tool_name" == "Read" && -f "$target" ]]; then
  file_size=$(stat -f%z "$target" 2>/dev/null || echo 0)
  if [[ "$file_size" -gt 512000 ]]; then
    size_kb=$((file_size / 1024))
    pretooluse_allow "[Guard] Warning: $target is ${size_kb}KB (>500KB). Consider using offset/limit parameters."
  fi
fi

pretooluse_allow
