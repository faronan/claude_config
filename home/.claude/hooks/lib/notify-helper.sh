#!/usr/bin/env bash
# 通知フック共通ヘルパー関数

# OSC エスケープシーケンス用サニタイズ（制御文字を除去）
sanitize() {
  local s="$1"
  # BEL(\a), ESC(\e), ST(\e\\) を除去（シーケンスの誤終端を防止）
  s=$(printf '%s' "$s" | tr -d '\a\e')
  # 改行をスペースに変換
  s="${s//$'\n'/ }"
  printf '%s' "$s"
}

# Ghostty OSC 777 で通知を送信（クリックでウィンドウフォーカス）
send_notification() {
  local title="$1"
  local subtitle="$2"
  local message="$3"

  # subtitle と message を結合して body を構成
  local body=""
  if [[ -n "$subtitle" && -n "$message" ]]; then
    body="${subtitle} | ${message}"
  else
    body="${subtitle}${message}"
  fi

  local safe_title safe_body
  safe_title=$(sanitize "$title")
  safe_body=$(sanitize "$body")

  # /dev/tty 経由でターミナルに OSC 777 を送信
  if [[ -w /dev/tty ]]; then
    printf '\e]777;notify;%s;%s\a' "$safe_title" "$safe_body" > /dev/tty 2>/dev/null || true
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
