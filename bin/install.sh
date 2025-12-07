#!/usr/bin/env bash
set -euo pipefail

#=== 設定 ==============================
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_ROOT="${HOME}"
SOURCE_ROOT="${REPO_ROOT}/home"
BACKUP_ROOT="${HOME_ROOT}/.claude-config-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
SKIP_MCP=false

#=== ヘルプ ============================
show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Claude Code グローバル設定をインストールします。

OPTIONS:
  -n, --dry-run    実際には実行せず、何が行われるかを表示
  --no-mcp         MCP サーバーのセットアップをスキップ
  -h, --help       このヘルプを表示

EXAMPLES:
  $(basename "$0")              # 通常インストール
  $(basename "$0") --dry-run    # 確認のみ
  $(basename "$0") --no-mcp     # MCP セットアップをスキップ
EOF
}

#=== 引数解析 ==========================
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-mcp)
      SKIP_MCP=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

#=== 関数 ==============================
log() {
  echo "[$(date '+%H:%M:%S')] $1"
}

backup_and_link() {
  local src="$1"
  local dest="$2"

  if $DRY_RUN; then
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      log "[DRY-RUN] Would backup: $dest"
    fi
    log "[DRY-RUN] Would link: $dest -> $src"
    return
  fi

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

  if $SKIP_MCP; then
    log "MCP setup skipped (--no-mcp)"
    return
  fi

  # Claude Code がインストールされているか確認
  if ! command -v claude &> /dev/null; then
    log "Claude Code not found. Skipping MCP setup."
    log ""
    log "After installing Claude Code, run these commands:"
    log "  claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp"
    log "  claude mcp add --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking"
    log "  claude mcp add --scope user -e GITHUB_PERSONAL_ACCESS_TOKEN='\${GITHUB_TOKEN}' github -- npx -y @modelcontextprotocol/server-github"
    return
  fi

  if $DRY_RUN; then
    log "[DRY-RUN] Would configure MCP servers:"
    log "[DRY-RUN]   - context7 (npx -y @upstash/context7-mcp)"
    log "[DRY-RUN]   - sequential-thinking (npx -y @modelcontextprotocol/server-sequential-thinking)"
    log "[DRY-RUN]   - github (npx -y @modelcontextprotocol/server-github)"
    return
  fi

  log "Setting up MCP servers..."

  # Context7（最新ドキュメント取得）
  claude mcp remove context7 --scope user 2>/dev/null || true
  claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp
  log "  ✓ context7 added"

  # Sequential Thinking（複雑な問題の構造化思考）
  claude mcp remove sequential-thinking --scope user 2>/dev/null || true
  claude mcp add --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
  log "  ✓ sequential-thinking added"

  # Note: fetch MCP は不要（Claude Code 組み込みの Fetch/WebFetch で十分）

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
  if $DRY_RUN; then
    log "=== DRY-RUN MODE ==="
  fi
  log "Starting installation..."
  log "Repo root:  $REPO_ROOT"
  log "Home root:  $HOME_ROOT"
  log "Source:     $SOURCE_ROOT"
  echo

  # .claude ディレクトリ内のファイル/ディレクトリをリンク
  if [ -d "${SOURCE_ROOT}/.claude" ]; then
    # まず .claude ディレクトリ自体を作成
    if $DRY_RUN; then
      log "[DRY-RUN] Would create: ${HOME_ROOT}/.claude"
    else
      mkdir -p "${HOME_ROOT}/.claude"
    fi

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
  if $DRY_RUN; then
    log "[DRY-RUN] Symlinks installation preview complete!"
  else
    log "Symlinks installation complete!"
    if [ -d "$BACKUP_ROOT" ]; then
      log "Previous files backed up to: $BACKUP_ROOT"
    fi
  fi

  # MCP サーバーのセットアップ
  setup_mcp_servers

  echo
  if $DRY_RUN; then
    log "=== DRY-RUN Complete (no changes made) ==="
  else
    log "=== All Done ==="
  fi
}

main "$@"
