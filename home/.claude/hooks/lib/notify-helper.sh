#!/usr/bin/env bash
# 通知フック共通ヘルパー関数

# システム注入タグ (<system-reminder> 等) を内容ごと除去
# 切り詰め前に呼び出すこと（切り詰め後は閉じタグが欠損しマッチしない）
strip_system_tags() {
  local s="$1"
  s="${s//$'\n'/ }"
  # <tag>content</tag> ペアを内容ごと除去
  s=$(printf '%s' "$s" | sed -E 's/<[a-z][a-z0-9_-]*>[^<]*<\/[a-z][a-z0-9_-]*>//g')
  # 残った孤立タグを除去
  s=$(printf '%s' "$s" | sed 's/<[^>]*>//g')
  # 連続スペースを圧縮し先頭末尾の空白を除去
  s=$(printf '%s' "$s" | tr -s ' ' | sed 's/^ //;s/ $//')
  printf '%s' "$s"
}

# OSC エスケープシーケンス用サニタイズ（制御文字を除去）
sanitize() {
  local s="$1"
  # BEL(0x07), ESC(0x1B) を除去（シーケンスの誤終端を防止）
  # NOTE: BSD tr (macOS) は \e を文字 'e' と解釈するため、8進表記を使用
  s=$(printf '%s' "$s" | tr -d '\007\033')
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
    request=$(strip_system_tags "$request")
    printf '%s' "${request:0:$max_len}"
  fi
}
