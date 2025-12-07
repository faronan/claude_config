# claude-config

Claude Code のグローバル設定ディレクトリ `~/.claude` を Git 管理するためのリポジトリ。

## 概要

新しいマシンでも `git clone` + `install.sh` で同一の Claude Code 環境を再現可能。

## 構成

```
claude-config/
├── home/                    # $HOME をルートとしたミラー
│   └── .claude/
│       ├── CLAUDE.md       # グローバルユーザー設定
│       ├── settings.json   # 権限・フック設定
│       ├── commands/       # スラッシュコマンド
│       ├── agents/         # サブエージェント
│       └── skills/         # スキル
├── templates/               # プロジェクト用テンプレート
│   ├── minimal/            # 最小限の設定
│   ├── typescript-web/     # TypeScript + React（Playwright MCP 付き）
│   └── python-data/        # Python データ分析（Jupyter MCP 付き）
├── bin/
│   └── install.sh          # デプロイスクリプト
└── README.md
```

## セットアップ

### 初回セットアップ

```bash
git clone git@github.com:<username>/claude-config.git ~/claude-config
cd ~/claude-config
chmod +x bin/install.sh
./bin/install.sh
```

### インストールオプション

```bash
# 通常インストール
./bin/install.sh

# 確認のみ（実際には変更しない）
./bin/install.sh --dry-run

# MCP セットアップをスキップ
./bin/install.sh --no-mcp

# ヘルプ表示
./bin/install.sh --help
```

### 新マシンでの再現

```bash
git clone git@github.com:<username>/claude-config.git ~/claude-config
~/claude-config/bin/install.sh
```

### 環境変数の設定

MCP サーバー（GitHub 等）で使用する環境変数を設定:

**Fish shell** (`~/.config/fish/conf.d/secrets.fish`):

```fish
set -gx GITHUB_TOKEN "ghp_xxxx"
```

**Zsh/Bash** (`~/.zshrc` or `~/.bashrc`):

```bash
export GITHUB_TOKEN="ghp_xxxx"
```

## MCP サーバー

MCP サーバーは `install.sh` 実行時に自動セットアップされます。

Claude Code 未インストール時は手動で以下を実行:

```bash
# Context7（最新ドキュメント取得）
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp

# Sequential Thinking（複雑な問題の構造化思考）
claude mcp add --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking

# GitHub（オプション、GITHUB_TOKEN が必要）
claude mcp add --scope user -e GITHUB_PERSONAL_ACCESS_TOKEN='${GITHUB_TOKEN}' github -- npx -y @modelcontextprotocol/server-github
```

> **Note**: Web コンテンツ取得には Claude Code 組み込みの Fetch/WebFetch ツールを使用します（MCP 不要）。

確認: `claude mcp list`

## 含まれる設定

### スラッシュコマンド

| コマンド | 説明 |
|----------|------|
| `/commit` | ステージ済み変更からコミットメッセージを生成 |
| `/pr` | PR 説明文を生成 |
| `/review` | コードレビューを実行 |
| `/plan` | タスクの実行計画を策定 |
| `/test` | テストを実行 |
| `/docs` | ドキュメントを生成 |
| `/refactor` | リファクタリング提案を実行 |

### サブエージェント

| エージェント | 説明 |
|--------------|------|
| `@code-reviewer` | コードレビュー専門 |
| `@explainer` | コード説明専門 |
| `@security-reviewer` | セキュリティレビュー専門 |
| `@performance-analyzer` | パフォーマンス分析専門 |
| `@refactoring-advisor` | リファクタリング提案専門 |

### スキル

| スキル | 説明 |
|--------|------|
| `commit-message` | Conventional Commits 形式のコミットメッセージ生成 |
| `pr-description` | PR 説明文のフォーマットルール |
| `documentation-style` | JSDoc/docstring/rustdoc のスタイルガイド |

### テンプレート

| テンプレート | 用途 | MCP サーバー |
|--------------|------|-------------|
| `minimal` | 最小限の設定 | なし |
| `typescript-web` | TypeScript + React | Playwright（E2E テスト） |
| `python-data` | Python データ分析 | Jupyter |

テンプレートの `.mcp.json` はプロジェクトスコープで自動読み込みされます。

## 推奨ツールチェーン（2025年）

この設定は以下のツールチェーンを前提としています:

| カテゴリ | ツール |
|---------|--------|
| JS/TS リンター/フォーマッター | **Biome**（新規）、ESLint + Prettier（既存） |
| Python パッケージ | **uv** |
| Python リンター/フォーマッター | **ruff** |
| ランタイムバージョン管理 | **mise** |
| シェル | **Fish** |

## カスタマイズ

設定変更は `home/` 以下のファイルを直接編集し、通常の Git ワークフローで管理。

シンボリックリンク方式のため、`claude config` での GUI 変更も自動的に Git 管理対象になる。

## 注意事項

- `settings.json` の `"Skill"` 許可がないと Skill が発火しない
- MCP サーバーは `claude mcp add` コマンドで管理（設定ファイル直接編集ではない）
- Fish shell では zsh/bash のコマンドがそのまま動かない場合があるので注意
