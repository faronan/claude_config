#!/usr/bin/env bash
# Codex notify command: send a Ghostty desktop notification.

set -euo pipefail

export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

SHARED_NOTIFY_LIB="${SHARED_NOTIFY_LIB:-$HOME/.shared/hooks/lib/notify-helper.sh}"

if [[ -f "$SHARED_NOTIFY_LIB" ]]; then
  # shellcheck disable=SC1090
  source "$SHARED_NOTIFY_LIB"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/../../.shared/hooks/lib/notify-helper.sh"
fi

json_get() {
  local query="$1"
  jq -r "$query // empty" 2>/dev/null || true
}

json_get_first() {
  local query="$1"
  jq -r "$query | if type == \"array\" then .[0] // empty else . // empty end" 2>/dev/null || true
}

if [[ $# -gt 0 ]]; then
  input="$1"
else
  input=$(cat || true)
fi

cwd=$(printf '%s' "$input" | json_get '.cwd')
event_type=$(printf '%s' "$input" | json_get '.type')
reason=$(printf '%s' "$input" | json_get '.reason')
message=$(printf '%s' "$input" | json_get '.message')
last_message=$(printf '%s' "$input" | json_get '."last-assistant-message" // .last_assistant_message')
input_message=$(printf '%s' "$input" | json_get_first '."input-messages" // .input_messages')

project_name="Codex"
if [[ -n "$cwd" ]]; then
  project_name=$(basename "$cwd")
elif [[ -n "${PWD:-}" ]]; then
  project_name=$(basename "$PWD")
fi

subtitle="タスク完了"
if [[ -n "$input_message" ]]; then
  subtitle=$(printf '%s' "$input_message" | truncate_chars 50)
elif [[ -n "$reason" ]]; then
  subtitle="$reason"
elif [[ -n "$event_type" ]]; then
  subtitle="$event_type"
fi

body="完了しました"
if [[ -n "$last_message" ]]; then
  body="$last_message"
elif [[ -n "$message" ]]; then
  body="$message"
fi

body=$(strip_system_tags "$body")
body=$(printf '%s' "$body" | truncate_chars 80)

send_notification "$project_name" "$subtitle" "$body"
