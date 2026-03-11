#!/bin/bash
# Stop フック: タスク完了通知（非同期実行用）
# async: true で実行されることを想定

export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/notify-helper.sh"

input=$(cat)

# ペイロードから情報を取得
cwd=$(echo "$input" | jq -r '.cwd // ""')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# プロジェクト名を取得
project_name=$(get_project_name "$cwd")

# 通知内容を初期化
title="${project_name:-Claude Code}"
subtitle="タスク完了"
message="完了しました"

# last_assistant_message フィールドから直接取得（v2.1.47+）
assistant_output=$(echo "$input" | jq -r '.last_assistant_message // ""' | tr '\n' ' ') || true
assistant_output=$(strip_system_tags "$assistant_output")
assistant_output="${assistant_output:0:80}"

# ユーザー依頼はトランスクリプトから取得（最初の1件のみ）
user_request=$(get_user_request "$transcript_path" 50)
[[ -n "$user_request" ]] && subtitle="$user_request"

[[ -n "$assistant_output" ]] && message="$assistant_output"

send_notification "$title" "$subtitle" "$message"

exit 0
