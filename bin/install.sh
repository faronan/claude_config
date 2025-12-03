#!/usr/bin/env bash
set -euo pipefail

#=== 設定 ==============================
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_ROOT="${HOME}"
SOURCE_ROOT="${REPO_ROOT}/home"
BACKUP_ROOT="${HOME_ROOT}/.claude-config-backup-$(date +%Y%m%d-%H%M%S)"

#=== 関数 ==============================
log() {
  echo "[$(date '+%H:%M:%S')] $1"
}

backup_and_link() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local rel="${dest#${HOME_ROOT}/}"
    local backup_path="${BACKUP_ROOT}/${rel}"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dest" "$backup_path"
    log "Backup: $dest -> $backup_path"
  fi

  ln -s "$src" "$dest"
  log "Link: $dest -> $src"
}

setup_mcp_servers() {
  echo
  log "=== MCP Servers Setup ==="

  # Claude Code がインストールされているか確認
  if ! command -v claude &> /dev/null; then
    log "Claude Code not found. Skipping MCP setup."
    log ""
    log "After installing Claude Code, run these commands:"
    log "  claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp"
    log "  claude mcp add --scope user fetch -- uvx mcp-server-fetch"
    log ""
    log "For GitHub MCP (optional):"
    log "  claude mcp add --scope user -e GITHUB_PERSONAL_ACCESS_TOKEN='\${GITHUB_TOKEN}' github -- npx -y @modelcontextprotocol/server-github"
    return
  fi

  log "Setting up MCP servers..."

  # Context7（最新ドキュメント取得）
  claude mcp remove context7 --scope user 2>/dev/null || true
  claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp
  log "  ✓ context7 added"

  # Fetch（Webコンテンツ取得）
  claude mcp remove fetch --scope user 2>/dev/null || true
  claude mcp add --scope user fetch -- uvx mcp-server-fetch
  log "  ✓ fetch added"

  # GitHub（常に追加、実行時に環境変数を評価）
  claude mcp remove github --scope user 2>/dev/null || true
  claude mcp add --scope user -e 'GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}' github -- npx -y @modelcontextprotocol/server-github
  log "  ✓ github added (requires GITHUB_TOKEN at runtime)"
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    log "    Note: GITHUB_TOKEN is not currently set. Set it before using GitHub MCP."
  fi

  log ""
  log "MCP servers configured! Verify with: claude mcp list"
}

#=== メイン処理 ========================
main() {
  log "Starting installation..."
  log "Repo root:  $REPO_ROOT"
  log "Home root:  $HOME_ROOT"
  log "Source:     $SOURCE_ROOT"
  echo

  # .claude ディレクトリ内のファイル/ディレクトリをリンク
  if [ -d "${SOURCE_ROOT}/.claude" ]; then
    # まず .claude ディレクトリ自体を作成
    mkdir -p "${HOME_ROOT}/.claude"

    # 直下のファイル・ディレクトリをリンク（隠しファイル含む）
    for src in "${SOURCE_ROOT}/.claude"/* "${SOURCE_ROOT}/.claude"/.*; do
      basename="$(basename "$src")"
      case "$basename" in
        .|..) continue ;;
      esac
      if [ -e "$src" ]; then
        dest="${HOME_ROOT}/.claude/${basename}"
        backup_and_link "$src" "$dest"
      fi
    done
  fi

  # home 直下のドットファイル（.claude 以外）
  for src in "${SOURCE_ROOT}"/.*; do
    basename="$(basename "$src")"
    case "$basename" in
      .|..|.claude) continue ;;
    esac
    if [ -f "$src" ]; then
      dest="${HOME_ROOT}/${basename}"
      backup_and_link "$src" "$dest"
    fi
  done

  echo
  log "Symlinks installation complete!"
  if [ -d "$BACKUP_ROOT" ]; then
    log "Previous files backed up to: $BACKUP_ROOT"
  fi

  # MCP サーバーのセットアップ
  setup_mcp_servers

  echo
  log "=== All Done ==="
}

main "$@"
