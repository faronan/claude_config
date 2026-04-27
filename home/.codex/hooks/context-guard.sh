#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat || true)
tool_name=$(printf '%s' "$input" | json_get '.tool_name')

case "$tool_name" in
  Read)
    target=$(printf '%s' "$input" | json_get '.tool_input.file_path')
    ;;
  Glob)
    target=$(printf '%s' "$input" | json_get '.tool_input.pattern')
    ;;
  mcp__*)
    target=$(printf '%s' "$input" | jq -r '.. | strings | select(length > 0)' 2>/dev/null | head -20 | tr '\n' ' ')
    ;;
  *)
    exit 0
    ;;
esac

if [[ -z "$target" ]]; then
  exit 0
fi

if reason=$(match_secret_pattern "$target"); then
  pretooluse_deny "$reason"
fi

if reason=$(match_blocked_dir "$target"); then
  # メッセージは Codex 既存の表現に合わせる
  pretooluse_deny "${reason/Blocked:/Blocked noisy read target:}"
fi

exit 0
