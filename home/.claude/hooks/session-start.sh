#!/usr/bin/env bash
# session-start.sh - セッション開始時の環境チェック

ensure_claude_code_tmpdir() {
  local tmpdir="${CLAUDE_CODE_TMPDIR:-}"
  local base_dir
  local hook_cwd="${1:-}"

  if [[ -z "$tmpdir" ]]; then
    return 0
  fi

  case "$tmpdir" in
    "~")
      tmpdir="$HOME"
      ;;
    "~/"*)
      tmpdir="$HOME/${tmpdir#~/}"
      ;;
    /*)
      ;;
    *)
      base_dir="${hook_cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}"
      tmpdir="$base_dir/$tmpdir"
      ;;
  esac

  if [[ "$tmpdir" == "/" ]]; then
    echo "[Session] Warning: refusing CLAUDE_CODE_TMPDIR=/"
    return 0
  fi

  if ! mkdir -p "$tmpdir" 2>/dev/null; then
    echo "[Session] Warning: cannot create CLAUDE_CODE_TMPDIR: $tmpdir"
    return 0
  fi

  if [[ ! -w "$tmpdir" ]]; then
    echo "[Session] Warning: CLAUDE_CODE_TMPDIR is not writable: $tmpdir"
  fi
}

if [[ -t 0 ]]; then
  hook_input=""
else
  hook_input="$(cat 2>/dev/null || true)"
fi
hook_cwd="$(printf '%s' "$hook_input" | jq -r '.cwd // empty' 2>/dev/null || true)"

# Claude Code creates session-specific files such as claude-<session>-cwd
# under CLAUDE_CODE_TMPDIR. The hook only guarantees that base directory exists.
ensure_claude_code_tmpdir "$hook_cwd"

# mise 経由のツール（ruff等）を検出するため Bash でも activate
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

brew_missing=()
mise_missing=()
for cmd in biome prettier; do
  command -v "$cmd" &> /dev/null || brew_missing+=("$cmd")
done
command -v ruff &> /dev/null || mise_missing+=("ruff")

missing=("${brew_missing[@]}" "${mise_missing[@]}")
if [ ${#missing[@]} -gt 0 ]; then
  echo "[Session] Missing tools: ${missing[*]}"
  install_cmds=()
  [ ${#brew_missing[@]} -gt 0 ] && install_cmds+=("brew install ${brew_missing[*]}")
  [ ${#mise_missing[@]} -gt 0 ] && install_cmds+=("mise use -g ruff@latest")
  echo "[Session] Install: $(IFS=' && '; echo "${install_cmds[*]}")"
fi

# Git 情報の表示
if git rev-parse --is-inside-work-tree &> /dev/null; then
  branch=$(git branch --show-current 2>/dev/null || echo "detached")
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "[Session] Git: $branch (uncommitted: $dirty)"
fi

# ランタイムバージョンの表示
node_ver=$(node --version 2>/dev/null || echo "not found")
python_ver=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "not found")
echo "[Session] Node: $node_ver / Python: $python_ver"

exit 0
