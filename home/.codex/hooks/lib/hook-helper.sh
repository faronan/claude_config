#!/usr/bin/env bash
# Codex CLI hooks 用ヘルパー
# common.sh + Codex 固有 (hook_context, stop_continue)

SHARED_LIB="${CODEX_SHARED_LIB:-$HOME/.shared/hooks/lib}"
# shellcheck disable=SC1091
source "$SHARED_LIB/common.sh"

# 拒否を返して終了
pretooluse_deny() {
  emit_pretooluse_deny "$1"
  exit 0
}

# Codex 固有: PostToolUse の context 注入用
hook_context() {
  local event="$1"
  local context="$2"
  jq -n --arg event "$event" --arg context "$context" '{
    hookSpecificOutput: {
      hookEventName: $event,
      additionalContext: $context
    }
  }'
}

# Codex 固有: Stop hook の継続フラグ
stop_continue() {
  jq -n '{continue: true}'
}
