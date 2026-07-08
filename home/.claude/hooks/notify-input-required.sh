#!/bin/bash
# Notification フック: 入力待ち通知（非同期実行用）
# Claude Codeがユーザー入力を待っている時に通知

export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/notify-helper.sh"

input=$(cat)

# ペイロードから情報を取得
cwd=$(echo "$input" | jq -r '.cwd // ""')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
notification_type=$(echo "$input" | jq -r '.notification_type // .notificationType // ""')
notification_message=$(echo "$input" | jq -r '.message // "入力を待っています"')

case "$notification_type" in
  ""|permission_prompt|idle_prompt|elicitation_dialog|agent_needs_input)
    ;;
  *)
    exit 0
    ;;
esac

# プロジェクト名を取得
project_name=$(get_project_name "$cwd")

# 通知内容を初期化
title="${project_name:-Claude Code}"
case "$notification_type" in
  agent_needs_input)
    subtitle="background agent 入力待ち"
    ;;
  elicitation_dialog)
    subtitle="MCP 入力待ち"
    ;;
  permission_prompt)
    subtitle="権限確認待ち"
    ;;
  *)
    subtitle="入力待ち"
    ;;
esac
message=$(printf '%s' "$notification_message" | truncate_chars 100)

# transcript_pathからユーザー依頼を取得
user_request=$(get_user_request "$transcript_path" 50)
[[ -n "$user_request" ]] && subtitle="$user_request"

send_notification "$title" "$subtitle" "$message"

exit 0
