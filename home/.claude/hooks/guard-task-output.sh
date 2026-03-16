#!/usr/bin/env bash
# PreToolUse フック: タスク出力ファイルの直接パースをブロック
# TaskOutput ツールの代わりに python3/bash で .output ファイルを
# 読み取ろうとする既知の問題 (#17591) への対策
# Exit codes: 0=許可, 2=ブロック

set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

case "$tool_name" in
  Bash)
    command=$(echo "$input" | jq -r '.tool_input.command // empty')
    # .claude/tmp 配下のタスク出力ファイルへのアクセスを検出
    if echo "$command" | grep -qE '\.claude/tmp.*tasks/.*\.output|\.claude/tmp.*/tasks/'; then
      cat <<EOF >&2
[TaskGuard] タスク出力ファイルの直接読み取りをブロックしました。
TaskOutput ツールを使用するか、タスク完了通知を待ってください。
コマンド: $(echo "$command" | head -c 200)
EOF
      exit 2
    fi
    ;;
  Read)
    file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
    if echo "$file_path" | grep -qE '\.claude/tmp.*/tasks/.*\.output'; then
      cat <<EOF >&2
[TaskGuard] タスク出力ファイルの直接読み取りをブロックしました。
TaskOutput ツールを使用してください。
ファイル: $file_path
EOF
      exit 2
    fi
    ;;
esac

exit 0
