#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat || true)
tool_name=$(printf '%s' "$input" | json_get '.tool_name')

case "$tool_name" in
  Read)
    target=$(printf '%s' "$input" | json_get '.tool_input.file_path')
    ;;
  Glob)
    target=$(printf '%s' "$input" | json_get '.tool_input.pattern')
    ;;
  mcp__*)
    target=$(printf '%s' "$input" | jq -r '.. | strings | select(length > 0)' 2>/dev/null | head -20 | tr '\n' ' ')
    ;;
  *)
    exit 0
    ;;
esac

if [[ -z "$target" ]]; then
  exit 0
fi

secret_patterns=(
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

for pattern in "${secret_patterns[@]}"; do
  if printf '%s' "$target" | grep -qE "$pattern" 2>/dev/null; then
    pretooluse_deny "[Security] Secret-like read target is blocked: $target"
  fi
done

blocked_dirs=(
  "node_modules/"
  ".git/"
  "dist/"
  "build/"
  ".next/"
  "__pycache__/"
)

for dir in "${blocked_dirs[@]}"; do
  if [[ "$target" == *"$dir"* ]]; then
    pretooluse_deny "[Guard] Blocked noisy read target: $target ($dir is not allowed)"
  fi
done

exit 0
