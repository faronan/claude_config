#!/usr/bin/env bash
# Shared notification helpers for Claude Code and Codex hooks.

strip_system_tags() {
  local s="$1"
  s="${s//$'\n'/ }"
  s=$(printf '%s' "$s" | sed -E 's/<[a-z][a-z0-9_-]*>[^<]*<\/[a-z][a-z0-9_-]*>//g')
  s=$(printf '%s' "$s" | sed 's/<[^>]*>//g')
  s=$(printf '%s' "$s" | tr -s ' ' | sed 's/^ //;s/ $//')
  printf '%s' "$s"
}

truncate_chars() {
  local max_len="$1"
  perl -CSDA -e '
    my $n = shift;
    local $/;
    my $input = <STDIN>;
    print substr($input // "", 0, $n);
  ' "$max_len"
}

sanitize_osc() {
  local s="$1"
  s=$(printf '%s' "$s" | LC_ALL=C tr -d '\007\033')
  s="${s//;/：}"
  printf '%s' "$s"
}

send_notification() {
  local title="$1"
  local subtitle="$2"
  local message="$3"

  local body=""
  if [[ -n "$subtitle" && -n "$message" ]]; then
    body="${subtitle} | ${message}"
  else
    body="${subtitle}${message}"
  fi

  local safe_title safe_body
  safe_title=$(sanitize_osc "$title")
  safe_body=$(sanitize_osc "$body")

  if [[ -w /dev/tty ]]; then
    { printf '\e]777;notify;%s;%s\a' "$safe_title" "$safe_body" > /dev/tty; } 2>/dev/null || true
  fi
}

get_project_name() {
  local cwd="$1"
  if [[ -n "$cwd" ]]; then
    basename "$cwd"
  fi
}

get_user_request() {
  local transcript_path="$1"
  local max_len="${2:-50}"

  if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    local request
    request=$(grep -m1 '"type":"user"' "$transcript_path" 2>/dev/null | \
      jq -r '.message.content // "" | if type == "array" then .[0].text // "" else . end' 2>/dev/null | \
      tr '\n' ' ') || true
    request=$(strip_system_tags "$request")
    printf '%s' "$request" | truncate_chars "$max_len"
  fi
}
