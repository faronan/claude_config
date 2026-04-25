#!/usr/bin/env bash
# Codex PreToolUse (Bash) hook: プロジェクト外への書き込みを検出・ブロック

input=$(cat) || exit 0
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0

if [[ -z "$command" ]]; then
  exit 0
fi

sanitized=$(printf '%s' "$command" | sed -E 's/[0-9]*>\/?dev\/(null|stdout|stderr|fd\/[0-9]+)//g; s/[0-9]*>&[0-9]+//g')

SYSTEM_DIRS="/(etc|var|sys|proc|opt|usr|Library|System)(/|$)"
HOME_DIRS="(~|\\\$HOME|\\\$\{HOME\})/"

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
    echo "[Security] プロジェクト外のディレクトリへの書き込みは許可されていません: $command"
    exit 1
  fi
done

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
    echo "[Security] ホームディレクトリへの直接書き込みは許可されていません: $command"
    exit 1
  fi
done

exit 0
