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
notification_message=$(echo "$input" | jq -r '.message // "入力を待っています"')

# プロジェクト名を取得
project_name=$(get_project_name "$cwd")

# 通知内容を初期化
title="${project_name:-Claude Code}"
subtitle="入力待ち"
message=$(printf '%s' "$notification_message" | truncate_chars 100)

# transcript_pathからユーザー依頼を取得
user_request=$(get_user_request "$transcript_path" 50)
[[ -n "$user_request" ]] && subtitle="$user_request"

send_notification "$title" "$subtitle" "$message"

exit 0
