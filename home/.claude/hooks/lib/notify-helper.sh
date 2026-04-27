#!/usr/bin/env bash
# Backward-compatible shim for Claude Code notification hooks.

SHARED_NOTIFY_LIB="${SHARED_NOTIFY_LIB:-$HOME/.shared/hooks/lib/notify-helper.sh}"

if [[ -f "$SHARED_NOTIFY_LIB" ]]; then
  # shellcheck disable=SC1090
  source "$SHARED_NOTIFY_LIB"
else
  SHIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  source "$SHIM_DIR/../../../.shared/hooks/lib/notify-helper.sh"
fi
