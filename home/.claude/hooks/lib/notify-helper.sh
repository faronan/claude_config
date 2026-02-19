#!/usr/bin/env bash
# 通知フック共通ヘルパー関数

# AppleScript文字列のサニタイズ（" と \ をエスケープ）
sanitize() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

# macOS通知を送信
send_notification() {
  local title="$1"
  local subtitle="$2"
  local message="$3"

  if [[ "$(uname)" == "Darwin" ]]; then
    osascript -e "display notification \"$(sanitize "$message")\" with title \"$(sanitize "$title")\" subtitle \"$(sanitize "$subtitle")\"" 2>/dev/null || true
  fi
}

# cwdからプロジェクト名を取得
get_project_name() {
  local cwd="$1"
  if [[ -n "$cwd" ]]; then
    basename "$cwd"
  fi
}

# transcript_pathからユーザーの最初のリクエストを取得
get_user_request() {
  local transcript_path="$1"
  local max_len="${2:-50}"

  if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    local request
    request=$(grep -m1 '"type":"user"' "$transcript_path" 2>/dev/null | \
      jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
      tr '\n' ' ') || true
    printf '%s' "${request:0:$max_len}"
  fi
}
