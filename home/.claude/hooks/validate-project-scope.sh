#!/bin/bash
# プロジェクト外ディレクトリへの書き込みを検出・ブロックするフック   # Exit codes: 0=許可, 2=ブロック

set -euo pipefail
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [[ -z "$command" ]]; then
  exit 0
fi

# 禁止ディレクトリパターン（システムディレクトリ + ホームディレクトリ直下）
FORBIDDEN_DIRS="^/(tmp|var|etc|dev|sys|proc|opt|usr|Library|System)"
HOME_PATTERNS="(~|\\\$HOME|\\\$\{HOME\})/"

# ファイル書き込みパターンを検出
WRITE_PATTERNS=(
  ">\s*${FORBIDDEN_DIRS}"
  ">>\s*${FORBIDDEN_DIRS}"
  "cat.*<<.*>\s*${FORBIDDEN_DIRS}"
  "tee\s+${FORBIDDEN_DIRS}"
  "cp\s+.*\s+${FORBIDDEN_DIRS}"
  "mv\s+.*\s+${FORBIDDEN_DIRS}"
  "mkdir\s+(-p\s+)?${FORBIDDEN_DIRS}"
  "touch\s+${FORBIDDEN_DIRS}"
)

for pattern in "${WRITE_PATTERNS[@]}"; do
  if echo "$command" | grep -qE "$pattern"; then
    cat <<EOF >&2
[Security] プロジェクト外のディレクトリへの書き込みは許可されていません。
コマンド: $command
プロジェクト内のディレクトリを使用してください。
EOF
    exit 2
  fi
done

# ホームディレクトリ（~/、$HOME/）への書き込みパターンを検出
HOME_WRITE_PATTERNS=(
  ">\s*${HOME_PATTERNS}"
  ">>\s*${HOME_PATTERNS}"
  "tee\s+${HOME_PATTERNS}"
  "cp\s+.*\s+${HOME_PATTERNS}"
  "mv\s+.*\s+${HOME_PATTERNS}"
  "mkdir\s+(-p\s+)?${HOME_PATTERNS}"
  "touch\s+${HOME_PATTERNS}"
)

for pattern in "${HOME_WRITE_PATTERNS[@]}"; do
  if echo "$command" | grep -qE "$pattern"; then
    cat <<EOF >&2
[Security] ホームディレクトリへの直接書き込みは許可されていません。
コマンド: $command
プロジェクト内のディレクトリを使用してください。
EOF
    exit 2
  fi
done

exit 0
