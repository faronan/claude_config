#!/usr/bin/env bash
# PreToolUse フック共通ヘルパー
# "hook error" 誤表示バグ (#17088, #34713) の回避策として
# hookSpecificOutput JSON を stdout に出力する

# 許可を返して終了（オプションで additionalContext を付与）
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
  local reason="$1"
  jq -n --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}
