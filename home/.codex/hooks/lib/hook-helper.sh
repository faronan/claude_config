#!/usr/bin/env bash

activate_mise() {
  if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)" >/dev/null 2>&1 || true
  fi
}

json_get() {
  local filter="$1"
  jq -r "$filter // empty" 2>/dev/null
}

pretooluse_deny() {
  local reason="$1"
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

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

stop_continue() {
  jq -n '{continue: true}'
}
