#!/bin/bash
# プロジェクト外ディレクトリへの書き込みを検出・ブロックするフック

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat) || pretooluse_allow
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || pretooluse_allow

if [[ -z "$command" ]]; then
  pretooluse_allow
fi

# チェック対象のコマンドから安全なリダイレクト（>/dev/null, 2>&1 等）を除去して判定
sanitized=$(printf '%s' "$command" | sed -E 's/[0-9]*>\/?dev\/(null|stdout|stderr|fd\/[0-9]+)//g; s/[0-9]*>&[0-9]+//g')

# 禁止システムディレクトリ（/dev, /tmp は除外: /dev/null は正当な使用、/tmp は CLAUDE_CODE_TMPDIR で制御）
SYSTEM_DIRS="/(etc|var|sys|proc|opt|usr|Library|System)(/|$)"
HOME_DIRS="(~|\\\$HOME|\\\$\{HOME\})/"

# システムディレクトリへの書き込みパターン
WRITE_PATTERNS=(
  "[^0-9]>\s*${SYSTEM_DIRS}"
  ">>\s*${SYSTEM_DIRS}"
  "tee\s+.*${SYSTEM_DIRS}"
  "cp\s+.*\s+${SYSTEM_DIRS}"
  "mv\s+.*\s+${SYSTEM_DIRS}"
  "mkdir\s+(-p\s+)?${SYSTEM_DIRS}"
  "touch\s+${SYSTEM_DIRS}"
)

for pattern in "${WRITE_PATTERNS[@]}"; do
  if printf '%s' "$sanitized" | grep -qE "$pattern" 2>/dev/null; then
    pretooluse_deny "[Security] プロジェクト外のディレクトリへの書き込みは許可されていません。コマンド: $command"
  fi
done

# ホームディレクトリ（~/、$HOME/）への書き込みパターン
HOME_WRITE_PATTERNS=(
  "[^0-9]>\s*${HOME_DIRS}"
  ">>\s*${HOME_DIRS}"
  "tee\s+.*${HOME_DIRS}"
  "cp\s+.*\s+${HOME_DIRS}"
  "mv\s+.*\s+${HOME_DIRS}"
  "mkdir\s+(-p\s+)?${HOME_DIRS}"
  "touch\s+${HOME_DIRS}"
)

for pattern in "${HOME_WRITE_PATTERNS[@]}"; do
  if printf '%s' "$sanitized" | grep -qE "$pattern" 2>/dev/null; then
    pretooluse_deny "[Security] ホームディレクトリへの直接書き込みは許可されていません。コマンド: $command"
  fi
done

pretooluse_allow
