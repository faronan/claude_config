#!/usr/bin/env bash
# Codex CLI / Claude Code 両方のフックで共有される基盤関数とデータ
# このファイルは home/.shared/hooks/lib/common.sh で管理し、
# bin/install.sh が ~/.shared/ に symlink する。
# 各ハーネス側 lib/hook-helper.sh から source される。

activate_mise() {
  local mise_bin=""

  if command -v mise >/dev/null 2>&1; then
    mise_bin="$(command -v mise)"
  elif [[ -x /opt/homebrew/bin/mise ]]; then
    mise_bin="/opt/homebrew/bin/mise"
  elif [[ -x /usr/local/bin/mise ]]; then
    mise_bin="/usr/local/bin/mise"
  elif [[ -x "$HOME/.local/bin/mise" ]]; then
    mise_bin="$HOME/.local/bin/mise"
  fi

  if [[ -n "$mise_bin" ]]; then
    eval "$("$mise_bin" activate bash)" >/dev/null 2>&1 || true
  fi
}

json_get() {
  local filter="$1"
  jq -r "$filter // empty" 2>/dev/null
}

# 両ハーネス共通の deny JSON 形式 (PreToolUse)
emit_pretooluse_deny() {
  local reason="$1"
  jq -n --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
}

SECRET_PATTERNS=(
  "(^|/)\.env(\..*)?$"
  "(^|/)\.aws(/|$)"
  "(^|/)\.kube(/|$)"
  "(^|/)\.netrc$"
  "(^|/)\.npmrc$"
  "(^|/)\.pypirc$"
  "(^|/)\.ssh(/|$)"
  "(^|/)\.git-credentials$"
  "(^|/)auth\.json$"
  "(^|/)credentials\.json$"
  "(^|/)hosts\.yml$"
  "(^|/)id_(rsa|dsa|ecdsa|ed25519)$"
  "(^|/)kubeconfig$"
  "\.kubeconfig$"
  "\.pem$"
  "\.key$"
  "(^|/)[^/]*(service-account|service_account)[^/]*\.json$"
  "(^|/)secrets?(/|$)"
)

BLOCKED_DIRS=(
  "node_modules/"
  ".git/"
  "dist/"
  "build/"
  ".next/"
  "__pycache__/"
)

# match_secret_pattern <target>
# マッチしたら deny 理由を stdout に出して return 0、なければ return 1
match_secret_pattern() {
  local target="$1"
  local pattern
  for pattern in "${SECRET_PATTERNS[@]}"; do
    if printf '%s' "$target" | grep -qE "$pattern" 2>/dev/null; then
      printf '[Security] Secret-like read target is blocked: %s' "$target"
      return 0
    fi
  done
  return 1
}

# match_secret_command <command>
# command 文字列内の secret-like path token を検出したら deny 理由を stdout に出して return 0
match_secret_command() {
  local command="$1"
  local token
  local unquoted

  while IFS= read -r token; do
    unquoted="${token#\'}"
    unquoted="${unquoted%\'}"
    unquoted="${unquoted#\"}"
    unquoted="${unquoted%\"}"

    if match_secret_pattern "$unquoted" >/dev/null; then
      printf '[Security] Secret-like command target is blocked: %s' "$unquoted"
      return 0
    fi
  done < <(
    printf '%s\n' "$command" |
      grep -Eo '(["'\'']?)([^[:space:];|&<>()]+/)?(\.env(\.[^[:space:];|&<>()]+)?|\.aws|\.kube|\.netrc|\.npmrc|\.pypirc|\.ssh|\.git-credentials|auth\.json|credentials\.json|hosts\.yml|id_(rsa|dsa|ecdsa|ed25519)|kubeconfig|[^[:space:];|&<>()]*(service-account|service_account)[^[:space:];|&<>()]*\.json|[^[:space:];|&<>()]+\.kubeconfig|[^[:space:];|&<>()]+\.pem|[^[:space:];|&<>()]+\.key|([^[:space:];|&<>()]+/)?secrets?/[^[:space:];|&<>()]+)(/[^[:space:];|&<>()]*)?(["'\'']?)' 2>/dev/null
  )

  return 1
}

# match_blocked_dir <target>
# マッチしたら deny 理由を stdout に出して return 0、なければ return 1
match_blocked_dir() {
  local target="$1"
  local dir
  for dir in "${BLOCKED_DIRS[@]}"; do
    if [[ "$target" == *"$dir"* ]]; then
      printf '[Guard] Blocked: %s (%s is not allowed)' "$target" "$dir"
      return 0
    fi
  done
  return 1
}
