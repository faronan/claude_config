#!/bin/bash
# Stop フック: タスク完了通知（非同期実行用）
# async: true で実行されることを想定

set -euo pipefail

input=$(cat)

# transcript_pathから会話ログを取得
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# 通知内容を初期化
title="Claude Code"
subtitle=""
message=""

if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
  # 最初のユーザー依頼を取得（40文字まで）
  user_request=$(grep -m1 '"type":"human"' "$transcript_path" 2>/dev/null | \
    jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
    tr '\n' ' ' | head -c 40)

  # 最後のアシスタント出力の冒頭を取得（60文字まで）
  assistant_output=$(tac "$transcript_path" 2>/dev/null | grep -m1 '"type":"assistant"' | \
    jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
    tr '\n' ' ' | head -c 60)

  subtitle="${user_request:-タスク完了}"
  message="${assistant_output:-完了しました}"
fi

# macOS通知
if [[ "$(uname)" == "Darwin" ]]; then
  osascript -e "display notification \"$message\" with title \"$title\" subtitle \"$subtitle\"" 2>/dev/null || true
fi

exit 0
