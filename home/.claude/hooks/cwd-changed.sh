#!/usr/bin/env bash
# CwdChanged フック: ディレクトリ変更時に mise 環境を自動リロード
# mise env の出力を CLAUDE_ENV_FILE に追記し、後続 Bash に反映する

set -euo pipefail

input=$(cat)
new_cwd=$(echo "$input" | jq -r '.new_cwd // .cwd // empty')

if [[ -z "$new_cwd" || ! -d "$new_cwd" ]]; then
  exit 0
fi

# mise がインストールされていなければスキップ
if ! command -v mise &>/dev/null; then
  exit 0
fi

# 新しいディレクトリに .mise.toml / .tool-versions があるか確認
has_mise_config=false
for f in .mise.toml .mise.local.toml .tool-versions; do
  if [[ -f "$new_cwd/$f" ]]; then
    has_mise_config=true
    break
  fi
done

if [[ "$has_mise_config" == "true" ]]; then
  env_output=$(mise env -s bash -C "$new_cwd" 2>/dev/null || true)
  if [[ -n "$env_output" && -n "${CLAUDE_ENV_FILE:-}" ]]; then
    {
      echo ""
      echo "# mise environment for $new_cwd"
      printf '%s\n' "$env_output"
    } >> "$CLAUDE_ENV_FILE" 2>/dev/null || true
  fi

  # バージョン情報を収集
  cd "$new_cwd"
  versions=$(mise current 2>/dev/null | head -5) || true
  if [[ -n "$versions" ]]; then
    echo "[mise] Activated environment for $(basename "$new_cwd"):"
    echo "$versions"
  fi
fi

exit 0
