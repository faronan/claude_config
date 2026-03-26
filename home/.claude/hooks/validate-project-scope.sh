#!/bin/bash
# プロジェクト外ディレクトリへの書き込みを検出・ブロックするフック
# Exit codes: 0=許可, 2=ブロック
#
# NOTE: Claude Code の既知バグ (#17088, #34713) により、exit 0 でも
# "PreToolUse:Bash hook error" が UI に表示されることがある。
# フック自体は正常に動作しており、表示上の問題のため無視して良い。

input=$(cat) || exit 0
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0

if [[ -z "$command" ]]; then
  exit 0
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
    cat <<EOF >&2
[Security] プロジェクト外のディレクトリへの書き込みは許可されていません。
コマンド: $command
プロジェクト内のディレクトリを使用してください。
EOF
    exit 2
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
    cat <<EOF >&2
[Security] ホームディレクトリへの直接書き込みは許可されていません。
コマンド: $command
プロジェクト内のディレクトリを使用してください。
EOF
    exit 2
  fi
done

exit 0
