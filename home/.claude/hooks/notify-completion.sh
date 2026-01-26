#!/bin/bash
# Stop フック: タスク完了通知（非同期実行用）
# async: true で実行されることを想定

set -euo pipefail

input=$(cat)

# セッション情報を取得
session_id=$(echo "$input" | jq -r '.session_id // "unknown"' | cut -c1-8)

# macOS通知
if [[ "$(uname)" == "Darwin" ]]; then
  osascript -e "display notification \"Session: $session_id\" with title \"Claude Code\" subtitle \"タスク完了\"" 2>/dev/null || true
fi

# 音声通知（オプション）
# afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true

exit 0
