#!/usr/bin/env bash
# CwdChanged フック: ディレクトリ変更時に mise 環境を自動リロード
# mise activate 済みの環境変数を更新し、ツールバージョンを同期する

set -euo pipefail

input=$(cat)
new_cwd=$(echo "$input" | jq -r '.cwd // empty')

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
  # mise 環境をリロード（stdout に出力すると additionalContext としてモデルに渡される）
  cd "$new_cwd"
  eval "$(mise activate bash)" 2>/dev/null || true

  # バージョン情報を収集
  versions=$(mise current 2>/dev/null | head -5) || true
  if [[ -n "$versions" ]]; then
    echo "[mise] Activated environment for $(basename "$new_cwd"):"
    echo "$versions"
  fi
fi

exit 0
