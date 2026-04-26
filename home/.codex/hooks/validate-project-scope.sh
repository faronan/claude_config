#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/hook-helper.sh"

input=$(cat || true)
tool_name=$(printf '%s' "$input" | json_get '.tool_name')
command=$(printf '%s' "$input" | json_get '.tool_input.command')

if [[ "$tool_name" != "Bash" || -z "$command" ]]; then
  exit 0
fi

sanitized=$(printf '%s' "$command" | sed -E 's/[0-9]*>\/?dev\/(null|stdout|stderr|fd\/[0-9]+)//g; s/[0-9]*>&[0-9]+//g')

dangerous_patterns=(
  "(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^;&|[:space:]]+)?[[:space:]]+push([^;&|]*[[:space:]])(-f|--force|--force-with-lease)([[:space:]]|$)"
  "(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^;&|[:space:]]+)?[[:space:]]+clean([^;&|]*[[:space:]])-[A-Za-z]*f[A-Za-z]*d[A-Za-z]*([[:space:]]|$)"
  "(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^;&|[:space:]]+)?[[:space:]]+clean([^;&|]*[[:space:]])-[A-Za-z]*d[A-Za-z]*f[A-Za-z]*([[:space:]]|$)"
  "(^|[;&|[:space:]])rm[[:space:]]+([^;&|]*[[:space:]])-[A-Za-z]*r[A-Za-z]*f[A-Za-z]*[[:space:]]+(/|~|\\\$HOME|\\\$\{HOME\})([[:space:]]|$)"
  "(^|[;&|[:space:]])rm[[:space:]]+([^;&|]*[[:space:]])-[A-Za-z]*f[A-Za-z]*r[A-Za-z]*[[:space:]]+(/|~|\\\$HOME|\\\$\{HOME\})([[:space:]]|$)"
  "(^|[;&|[:space:]])chmod[[:space:]]+([^;&|]*[[:space:]])?777([[:space:]]|$)"
  "(^|[;&|[:space:]])su([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])repo[[:space:]]+(delete|archive)([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])secret([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])variable[[:space:]]+(set|delete)([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])ssh-key[[:space:]]+(add|delete)([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])gpg-key[[:space:]]+(add|delete)([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])auth[[:space:]]+(login|logout)([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])pr[[:space:]]+merge([[:space:]]|$)"
  "(^|[;&|[:space:]])gh([^;&|]*[[:space:]])api([^;&|]*[[:space:]])(-X|--method)[[:space:]]+(POST|PUT|PATCH|DELETE)([[:space:]]|$)"
  "(^|[;&|[:space:]])npm([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(install|ci)([[:space:]]|$)"
  "(^|[;&|[:space:]])pnpm([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(install|add)([[:space:]]|$)"
  "(^|[;&|[:space:]])yarn([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(install|add)([[:space:]]|$)"
  "(^|[;&|[:space:]])pip([0-9.]*)?([[:space:]]|$)"
  "(^|[;&|[:space:]])python3?([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+-m[[:space:]]+pip([[:space:]]|$)"
  "(curl|wget)[^;&]*[|][[:space:]]*(bash|sh)([[:space:]]|$)"
)

for pattern in "${dangerous_patterns[@]}"; do
  if printf '%s' "$sanitized" | grep -qE "$pattern" 2>/dev/null; then
    pretooluse_deny "[Security] Risky command variant is blocked: $command"
  fi
done

system_dirs="/(etc|var|sys|proc|opt|usr|Library|System)(/|$)"
home_dirs="(~|\\\$HOME|\\\$\{HOME\})/"

write_patterns=(
  "[^0-9]>\s*${system_dirs}"
  ">>\s*${system_dirs}"
  "tee\s+.*${system_dirs}"
  "cp\s+.*\s+${system_dirs}"
  "mv\s+.*\s+${system_dirs}"
  "mkdir\s+(-p\s+)?${system_dirs}"
  "touch\s+${system_dirs}"
  "[^0-9]>\s*${home_dirs}"
  ">>\s*${home_dirs}"
  "tee\s+.*${home_dirs}"
  "cp\s+.*\s+${home_dirs}"
  "mv\s+.*\s+${home_dirs}"
  "mkdir\s+(-p\s+)?${home_dirs}"
  "touch\s+${home_dirs}"
)

for pattern in "${write_patterns[@]}"; do
  if printf '%s' "$sanitized" | grep -qE "$pattern" 2>/dev/null; then
    pretooluse_deny "[Security] Writing outside the workspace is blocked: $command"
  fi
done

exit 0
