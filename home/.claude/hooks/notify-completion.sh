#!/bin/bash
# Stop フック: タスク完了通知（非同期実行用）
# async: true で実行されることを想定

export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

input=$(cat)

# transcript_pathから会話ログを取得
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# 通知内容を初期化
title="Claude Code"
subtitle="タスク完了"
message="完了しました"

if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
  # 最初のユーザー依頼を取得
  user_request=$(grep -m1 '"type":"user"' "$transcript_path" 2>/dev/null | \
    jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
    tr '\n' ' ') || true
  # 文字数で切る（バイトではなく）
  user_request="${user_request:0:40}"

  # 最後のアシスタント出力の冒頭を取得
  # macOSでは tail -r を使用（tacの代替）
  assistant_output=$(tail -r "$transcript_path" 2>/dev/null | grep -m1 '"type":"assistant"' | \
    jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
    tr '\n' ' ') || true
  # 文字数で切る（バイトではなく）
  assistant_output="${assistant_output:0:60}"

  [[ -n "$user_request" ]] && subtitle="$user_request"
  [[ -n "$assistant_output" ]] && message="$assistant_output"
fi

# macOS通知
if [[ "$(uname)" == "Darwin" ]]; then
  osascript -e "display notification \"$message\" with title \"$title\" subtitle \"$subtitle\"" 2>/dev/null || true
fi

exit 0
