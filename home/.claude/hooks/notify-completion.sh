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
active_background_count=$(echo "$input" | jq '
  [.background_tasks[]? |
    select(((.status // "") | ascii_downcase) as $s |
      ($s != "completed" and $s != "done" and $s != "failed" and
       $s != "cancelled" and $s != "canceled" and $s != "retired"))] | length
' 2>/dev/null || echo 0)
active_cron_count=$(echo "$input" | jq '
  [.session_crons[]? |
    select(((.status // "") | ascii_downcase) as $s |
      ($s != "completed" and $s != "done" and $s != "failed" and
       $s != "cancelled" and $s != "canceled" and $s != "retired"))] | length
' 2>/dev/null || echo 0)
active_background_summary=$(echo "$input" | jq -r '
  [.background_tasks[]? |
    select(((.status // "") | ascii_downcase) as $s |
      ($s != "completed" and $s != "done" and $s != "failed" and
       $s != "cancelled" and $s != "canceled" and $s != "retired")) |
    "\(.type // "task"):\(.status // "unknown")"] |
  unique | join(", ")
' 2>/dev/null || true)
active_cron_summary=$(echo "$input" | jq -r '
  [.session_crons[]? |
    select(((.status // "") | ascii_downcase) as $s |
      ($s != "completed" and $s != "done" and $s != "failed" and
       $s != "cancelled" and $s != "canceled" and $s != "retired")) |
    "\(.type // "cron"):\(.status // "scheduled")"] |
  unique | join(", ")
' 2>/dev/null || true)

# プロジェクト名を取得
project_name=$(get_project_name "$cwd")

# 通知内容を初期化
title="${project_name:-Claude Code}"
subtitle="応答完了"
message="応答しました"

# last_assistant_message フィールドから直接取得（v2.1.47+）
assistant_output=$(echo "$input" | jq -r '.last_assistant_message // ""' | tr '\n' ' ') || true
assistant_output=$(strip_system_tags "$assistant_output")
assistant_output=$(printf '%s' "$assistant_output" | truncate_chars 80)

# ユーザー依頼はトランスクリプトから取得（最初の1件のみ）
user_request=$(get_user_request "$transcript_path" 50)
[[ -n "$user_request" ]] && subtitle="$user_request"

[[ -n "$assistant_output" ]] && message="$assistant_output"

if (( active_background_count > 0 || active_cron_count > 0 )); then
  task_parts=()
  (( active_background_count > 0 )) && task_parts+=("background:${active_background_count}${active_background_summary:+ (${active_background_summary})}")
  (( active_cron_count > 0 )) && task_parts+=("cron:${active_cron_count}${active_cron_summary:+ (${active_cron_summary})}")
  task_state="${task_parts[0]}"
  for part in "${task_parts[@]:1}"; do
    task_state="${task_state}, ${part}"
  done
  message=$(printf '%s / background処理が継続中: %s' "$message" "$task_state" | truncate_chars 120)
  [[ -z "$user_request" ]] && subtitle="応答完了（background処理あり）"
fi

send_notification "$title" "$subtitle" "$message"

exit 0
