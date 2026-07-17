#!/usr/bin/env bash
set -euo pipefail

#=== 設定 ==============================
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_ROOT="${HOME}"
SOURCE_ROOT="${REPO_ROOT}/home"
BACKUP_ROOT="${HOME_ROOT}/.claude-config-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
SKIP_MCP=false
CODEX_CONFIG_ONLY=false

#=== ヘルプ ============================
show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Claude Code グローバル設定をインストールします。

OPTIONS:
  -n, --dry-run    実際には実行せず、何が行われるかを表示
  --no-mcp         MCP サーバーのセットアップをスキップ
  --codex-config-only
                   Codex config.toml の生成・merge のみ実行
  -h, --help       このヘルプを表示

EXAMPLES:
  $(basename "$0")              # 通常インストール
  $(basename "$0") --dry-run    # 確認のみ
  $(basename "$0") --no-mcp     # MCP セットアップをスキップ
  $(basename "$0") --codex-config-only --dry-run
                                # Codex config 反映の確認のみ
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
    --codex-config-only)
      CODEX_CONFIG_ONLY=true
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

extract_codex_local_config() {
  local config="$1"

  if [ ! -f "$config" ]; then
    return 0
  fi

  awk '
    function is_repo_managed_mcp(header) {
      return header ~ /^\[\[?mcp_servers\."?context7"?([.\]]|$)/ ||
             header ~ /^\[\[?mcp_servers\."?sequential-thinking"?([.\]]|$)/
    }

    function keep_table(header) {
      return header ~ /^\[\[?projects\./ ||
             header ~ /^\[\[?marketplaces\./ ||
             header ~ /^\[\[?plugins\./ ||
             header == "[hooks.state]" ||
             header == "[[hooks.state]]" ||
             header ~ /^\[\[?hooks\.state\./ ||
             header == "[tui.model_availability_nux]" ||
             header == "[[tui.model_availability_nux]]" ||
             header ~ /^\[\[?notice(\.|])/ ||
             header ~ /^\[\[?desktop(\.|])/ ||
             (header ~ /^\[\[?mcp_servers\./ && !is_repo_managed_mcp(header))
    }

    /^\[+[^]]+\]+$/ {
      keep = keep_table($0)
      if (keep) {
        if (printed) {
          print ""
        }
        printed = 1
        print
      }
      next
    }

    keep {
      print
    }
  ' "$config"
}

link_codex_rules() {
  local source_rules="$1"
  local dest_rules="$2"

  if $DRY_RUN; then
    log "[DRY-RUN] Would link managed Codex rules individually: $dest_rules <- $source_rules"
    log "[DRY-RUN] Would preserve local Codex-managed rule: $dest_rules/default.rules"
    return
  fi

  if [ -L "$dest_rules" ]; then
    local local_default=""
    if [ -f "$dest_rules/default.rules" ]; then
      local_default="$(mktemp "${HOME_ROOT}/.codex/default.rules.XXXXXX")"
      cp "$dest_rules/default.rules" "$local_default"
    fi

    local rel="${dest_rules#${HOME_ROOT}/}"
    local backup_path="${BACKUP_ROOT}/${rel}"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dest_rules" "$backup_path"
    log "Backup: $dest_rules -> $backup_path"
    mkdir -p "$dest_rules"

    if [ -n "$local_default" ]; then
      mv "$local_default" "$dest_rules/default.rules"
      log "Preserved local rule: $dest_rules/default.rules"
    fi
  else
    mkdir -p "$dest_rules"
  fi

  local src
  local basename
  for src in "$source_rules"/* "$source_rules"/.*; do
    basename="$(basename "$src")"
    case "$basename" in
      .|..|default.rules) continue ;;
    esac
    if [ -e "$src" ]; then
      backup_and_link "$src" "$dest_rules/$basename"
    fi
  done
}

render_codex_base_config() {
  local base_config="$1"
  awk -v home="$HOME_ROOT" -v source_root="$SOURCE_ROOT" '
    {
      gsub(/__HOME__/, home)
      gsub(/__SOURCE_ROOT__/, source_root)
      print
    }
  ' "$base_config"
}

install_codex_config() {
  local base_config="${SOURCE_ROOT}/.codex/config.base.toml"
  local dest="${HOME_ROOT}/.codex/config.toml"

  if [ ! -f "$base_config" ]; then
    return
  fi

  if ! command -v codex &> /dev/null; then
    log "Codex not found. Skipping Codex config setup."
    return
  fi

  if $DRY_RUN; then
    log "[DRY-RUN] Would merge Codex config: $dest from $base_config"
    log "[DRY-RUN] Would preserve local Codex state tables: projects, marketplaces, plugins, hooks.state, tui.model_availability_nux, notice, desktop, non-base mcp_servers"
    return
  fi

  local local_state
  local_state="$(extract_codex_local_config "$dest")"

  local tmp_config
  tmp_config="$(mktemp "${HOME_ROOT}/.codex/config.toml.XXXXXX")"
  trap 'rm -f "$tmp_config"' RETURN
  chmod 600 "$tmp_config"
  render_codex_base_config "$base_config" > "$tmp_config"

  if [ -n "$local_state" ]; then
    {
      printf '\n\n'
      printf '# Local Codex state preserved by bin/install.sh. Do not commit this block.\n'
      printf '%s\n' "$local_state"
    } >> "$tmp_config"
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local rel="${dest#${HOME_ROOT}/}"
    local backup_path="${BACKUP_ROOT}/${rel}"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dest" "$backup_path"
    log "Backup: $dest -> $backup_path"
  fi

  mv "$tmp_config" "$dest"
  tmp_config=""
  trap - RETURN
  log "Merge: $dest <- $base_config"
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
    log "  claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp"
    log "  claude mcp add sequential-thinking --scope user -- npx -y @modelcontextprotocol/server-sequential-thinking"
    log "  claude mcp add tavily-remote-mcp --transport http https://mcp.tavily.com/mcp/"
    log "  claude mcp add github --scope user -e GITHUB_PERSONAL_ACCESS_TOKEN='\${GITHUB_TOKEN}' -- npx -y @modelcontextprotocol/server-github"
    return
  fi

  if $DRY_RUN; then
    log "[DRY-RUN] Would configure MCP servers:"
    log "[DRY-RUN]   - context7 (npx -y @upstash/context7-mcp)"
    log "[DRY-RUN]   - sequential-thinking (npx -y @modelcontextprotocol/server-sequential-thinking)"
    log "[DRY-RUN]   - tavily-remote-mcp (https://mcp.tavily.com/mcp/, requires OAuth authentication)"
    log "[DRY-RUN]   - github (npx -y @modelcontextprotocol/server-github)"
    return
  fi

  log "Setting up MCP servers..."

  # Context7（最新ドキュメント取得）
  claude mcp remove context7 --scope user 2>/dev/null || true
  claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp
  log "  ✓ context7 added"

  # Sequential Thinking（複雑な問題の構造化思考）
  claude mcp remove sequential-thinking --scope user 2>/dev/null || true
  claude mcp add sequential-thinking --scope user -- npx -y @modelcontextprotocol/server-sequential-thinking
  log "  ✓ sequential-thinking added"

  # Tavily（Web 検索・既知 URL 抽出。OAuth は次回 Claude Code セッションまたは /mcp で完了）
  claude mcp remove tavily-remote-mcp --scope local 2>/dev/null || true
  claude mcp add tavily-remote-mcp --transport http https://mcp.tavily.com/mcp/
  log "  ✓ tavily-remote-mcp added (authenticate with /mcp or a new Claude Code session)"

  # GitHub（常に追加、実行時に環境変数を評価）
  claude mcp remove github --scope user 2>/dev/null || true
  claude mcp add github --scope user -e 'GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}' -- npx -y @modelcontextprotocol/server-github
  log "  ✓ github added (requires GITHUB_TOKEN at runtime)"
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    log "    Note: GITHUB_TOKEN is not currently set. Set it before using GitHub MCP."
  fi

  log ""
  log "MCP servers configured! Verify with: claude mcp list"
}

setup_codex() {
  echo
  log "=== Codex Setup ==="

  if ! command -v codex &> /dev/null; then
    log "Codex not found. Skipping Codex setup."
    log "Install Codex first: npm install -g @openai/codex"
    return
  fi

  if $DRY_RUN; then
    log "[DRY-RUN] Would create: ${HOME_ROOT}/.codex"
    log "[DRY-RUN] Would link: ~/.codex/* -> ${SOURCE_ROOT}/.codex/* except config.toml/config.base.toml/rules"
    install_codex_config
    link_codex_rules "${SOURCE_ROOT}/.codex/rules" "${HOME_ROOT}/.codex/rules"
    return
  fi

  mkdir -p "${HOME_ROOT}/.codex"

  install_codex_config

  if [ -d "${SOURCE_ROOT}/.codex" ]; then
    for src in "${SOURCE_ROOT}/.codex"/* "${SOURCE_ROOT}/.codex"/.*; do
      basename="$(basename "$src")"
      case "$basename" in
        .|..|config.toml|config.base.toml|rules) continue ;;
      esac
      if [ -e "$src" ]; then
        dest="${HOME_ROOT}/.codex/${basename}"
        backup_and_link "$src" "$dest"
      fi
    done

    if [ -d "${SOURCE_ROOT}/.codex/rules" ]; then
      link_codex_rules "${SOURCE_ROOT}/.codex/rules" "${HOME_ROOT}/.codex/rules"
    fi
  fi

  log "Codex setup complete!"
}

setup_agents() {
  echo
  log "=== Agents Setup ==="

  if [ -d "${SOURCE_ROOT}/.agents/skills" ]; then
    local skills_source="${SOURCE_ROOT}/.agents/skills"
  else
    log "ERROR: Codex/Agents skills directory not found: ${SOURCE_ROOT}/.agents/skills"
    log "Refusing to fall back to Claude skills because that can reintroduce Claude Code-only tool assumptions."
    return 1
  fi

  if $DRY_RUN; then
    log "[DRY-RUN] Would create: ${HOME_ROOT}/.agents"
    log "[DRY-RUN] Would link skills from: $skills_source"
  else
    mkdir -p "${HOME_ROOT}/.agents"
  fi

  backup_and_link "$skills_source" "${HOME_ROOT}/.agents/skills"
  log "Agents setup complete!"
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

  if $CODEX_CONFIG_ONLY; then
    log "=== Codex Config Only ==="
    install_codex_config
    echo
    if $DRY_RUN; then
      log "=== DRY-RUN Complete (no changes made) ==="
    else
      log "=== Codex Config Done ==="
    fi
    return
  fi

  # .shared ディレクトリのリンク（両ハーネスから参照される共通 lib）
  # .claude / .codex より先に展開して、各 hook-helper.sh が source できる状態にする
  if [ -d "${SOURCE_ROOT}/.shared" ]; then
    backup_and_link "${SOURCE_ROOT}/.shared" "${HOME_ROOT}/.shared"
  fi

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

  # Biome グローバル設定（プロジェクトに biome.json がない場合のフォールバック）
  if [ -f "${SOURCE_ROOT}/biome/biome.json" ]; then
    local biome_config_dir="${HOME_ROOT}/Library/Application Support/biome"
    backup_and_link "${SOURCE_ROOT}/biome/biome.json" "${biome_config_dir}/biome.json"
  fi

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

  # Codex のセットアップ
  setup_codex

  # Codex/Agents 用スキルのセットアップ（Claude 用から分岐したコピー）
  setup_agents

  echo
  if $DRY_RUN; then
    log "=== DRY-RUN Complete (no changes made) ==="
  else
    log "=== All Done ==="
  fi
}

main "$@"
