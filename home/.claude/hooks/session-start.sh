#!/usr/bin/env bash
# session-start.sh - セッション開始時の環境チェック

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
exit 0
