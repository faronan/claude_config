#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_SKILLS="${REPO_ROOT}/home/.claude/skills"
AGENTS_SKILLS="${REPO_ROOT}/home/.agents/skills"

fail=0

mark_fail() {
  printf 'ERROR: %s\n' "$*" >&2
  fail=1
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local message="$3"

  if ! rg -q "$pattern" "$file"; then
    mark_fail "$message: $file"
  fi
}

if [ ! -d "$CLAUDE_SKILLS" ]; then
  mark_fail "Claude skills directory is missing: $CLAUDE_SKILLS"
fi

if [ ! -d "$AGENTS_SKILLS" ]; then
  mark_fail "Codex/Agents skills directory is missing: $AGENTS_SKILLS"
fi

if [ "$fail" -eq 0 ]; then
  claude_list="$(mktemp)"
  agents_list="$(mktemp)"
  trap 'rm -f "$claude_list" "$agents_list"' EXIT

  # Claude Code 専用 skill: Codex 側に存在しなくてよいもの。
  # 例: codex-delegate は Claude→Codex 橋渡し skill のため Codex 側には置かない。
  claude_only_pattern='^codex-delegate/'
  agents_only_pattern='^CODEX_COMPATIBILITY\.md$'

  find -L "$CLAUDE_SKILLS" -type f | sed "s#^${CLAUDE_SKILLS}/##" | sort > "$claude_list"
  find -L "$AGENTS_SKILLS" -type f | sed "s#^${AGENTS_SKILLS}/##" | sort | grep -Ev "$agents_only_pattern" > "$agents_list" || true

  missing_in_agents="$(comm -23 "$claude_list" "$agents_list" | grep -Ev "$claude_only_pattern" || true)"
  if [ -n "$missing_in_agents" ]; then
    printf 'Missing Codex/Agents skill files:\n%s\n' "$missing_in_agents" >&2
    fail=1
  fi

  extra_in_agents="$(comm -13 "$claude_list" "$agents_list" || true)"
  if [ -n "$extra_in_agents" ]; then
    printf 'Unexpected Codex/Agents-only skill files (not in Claude side):\n%s\n' "$extra_in_agents" >&2
    fail=1
  fi

  blocked_pattern='(^agent:|disable-model-invocation:|CLAUDE_SKILL_DIR|claude-code-guide|codex exec --full-auto|AskUserQuestion[[:space:]]*で|AskUserQuestionで|Task tool|Agent tool|確認なしで.*コミット|\b(error-investigator|code-implementer|app-verifier|verify-app|code-researcher|web-researcher|security-reviewer)\b)'
  if rg -n -g 'SKILL.md' "$blocked_pattern" "$AGENTS_SKILLS"; then
    mark_fail "Codex/Agents skills contain Claude Code-only execution tokens"
  fi

  require_pattern "${AGENTS_SKILLS}/quick-commit/SKILL.md" '<!-- codex-requires-confirmation: git-commit -->' "quick-commit must require explicit commit confirmation"
  require_pattern "${AGENTS_SKILLS}/smart-commit/SKILL.md" '<!-- codex-requires-confirmation: git-commit -->' "smart-commit must require explicit commit confirmation"
  require_pattern "${AGENTS_SKILLS}/gh-pr-create/SKILL.md" '<!-- codex-requires-confirmation: gh-pr-create -->' "gh-pr-create must require explicit PR confirmation"
  require_pattern "${AGENTS_SKILLS}/gh-pr-review/SKILL.md" '<!-- codex-requires-confirmation: gh-pr-action -->' "gh-pr-review must require explicit PR action confirmation"
  require_pattern "${AGENTS_SKILLS}/gh-issue-fix/SKILL.md" '<!-- codex-requires-confirmation: issue-implementation -->' "gh-issue-fix must require explicit implementation confirmation"
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

printf 'Codex/Agents skill drift check passed.\n'
