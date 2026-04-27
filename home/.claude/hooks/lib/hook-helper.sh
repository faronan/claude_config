#!/usr/bin/env bash
# Claude Code hooks 用ヘルパー
# common.sh + Claude 固有の pretooluse_allow (hook error バグ #17088, #34713 の回避策)

SHARED_LIB="${CLAUDE_SHARED_LIB:-$HOME/.shared/hooks/lib}"
# shellcheck disable=SC1091
source "$SHARED_LIB/common.sh"

# Claude 固有: PreToolUse は permissionDecision: "allow" を JSON で返さないと
# hook error が誤表示される (Claude Code バグ #17088, #34713)
pretooluse_allow() {
  local context="${1:-}"
  if [[ -n "$context" ]]; then
    jq -n --arg ctx "$context" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        additionalContext: $ctx
      }
    }'
  else
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow"
      }
    }'
  fi
  exit 0
}

# 拒否を返して終了
pretooluse_deny() {
  emit_pretooluse_deny "$1"
  exit 0
}
