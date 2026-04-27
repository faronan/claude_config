#!/usr/bin/env bash
# PreToolUse フック: 機密パスと不要ファイルの読み込みをブロック

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat) || pretooluse_allow

tool_name=$(printf '%s' "$input" | json_get '.tool_name') || pretooluse_allow

# 対象パスを取得（Read: file_path, Glob: pattern）
case "$tool_name" in
  Read)
    target=$(printf '%s' "$input" | json_get '.tool_input.file_path')
    ;;
  Glob)
    target=$(printf '%s' "$input" | json_get '.tool_input.pattern')
    ;;
  *)
    pretooluse_allow
    ;;
esac

if [[ -z "$target" ]]; then
  pretooluse_allow
fi

# secret check (settings.json deny の Read 制限を補完する深層防御)
if reason=$(match_secret_pattern "$target"); then
  pretooluse_deny "$reason"
fi

# noise check (node_modules, .git/, dist/, build/ 等)
if reason=$(match_blocked_dir "$target"); then
  pretooluse_deny "$reason"
fi

# 大容量ファイル警告（Read のみ、500KB超）
if [[ "$tool_name" == "Read" && -f "$target" ]]; then
  file_size=$(stat -f%z "$target" 2>/dev/null || echo 0)
  if [[ "$file_size" -gt 512000 ]]; then
    size_kb=$((file_size / 1024))
    pretooluse_allow "[Guard] Warning: $target is ${size_kb}KB (>500KB). Consider using offset/limit parameters."
  fi
fi

pretooluse_allow
