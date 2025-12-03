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

    # 直下のファイル・ディレクトリをリンク
    for src in "${SOURCE_ROOT}/.claude"/*; do
      if [ -e "$src" ]; then
        basename="$(basename "$src")"
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
  log "Installation complete!"
  if [ -d "$BACKUP_ROOT" ]; then
    log "Previous files backed up to: $BACKUP_ROOT"
  fi
}

main "$@"
