#!/bin/bash
# Stop フック: タスク完了通知（非同期実行用）
# async: true で実行されることを想定

export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

input=$(cat)

# ペイロードから情報を取得
cwd=$(echo "$input" | jq -r '.cwd // ""')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# プロジェクト名を取得（cwdのbasename）
project_name=""
if [[ -n "$cwd" ]]; then
  project_name=$(basename "$cwd")
fi

# 通知内容を初期化
# title: プロジェクト名（フォールバック: Claude Code）
# subtitle: ユーザー依頼
# message: アシスタント出力
title="${project_name:-Claude Code}"
subtitle="タスク完了"
message="完了しました"

if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
  # 最初のユーザー依頼を取得
  user_request=$(grep -m1 '"type":"user"' "$transcript_path" 2>/dev/null | \
    jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
    tr '\n' ' ') || true
  user_request="${user_request:0:50}"

  # 最後のアシスタント出力の冒頭を取得
  # macOSでは tail -r を使用（tacの代替）
  assistant_output=$(tail -r "$transcript_path" 2>/dev/null | grep -m1 '"type":"assistant"' | \
    jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
    tr '\n' ' ') || true
  assistant_output="${assistant_output:0:80}"

  [[ -n "$user_request" ]] && subtitle="$user_request"
  [[ -n "$assistant_output" ]] && message="$assistant_output"
fi

# AppleScript文字列のサニタイズ（" と \ をエスケープ）
sanitize() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

# macOS通知（osascript）
if [[ "$(uname)" == "Darwin" ]]; then
  osascript -e "display notification \"$(sanitize "$message")\" with title \"$(sanitize "$title")\" subtitle \"$(sanitize "$subtitle")\"" 2>/dev/null || true
fi

exit 0
