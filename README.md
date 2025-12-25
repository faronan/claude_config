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
│       ├── rules/          # 条件付きルール（パス指定可能）
│       ├── skills/         # スキル（自動発動）
│       ├── commands/       # スラッシュコマンド（手動実行）
│       └── agents/         # サブエージェント（並列実行用）
├── templates/               # プロジェクト用テンプレート
│   ├── GUIDE.md            # プロジェクト CLAUDE.md 作成ガイド
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
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp

# Sequential Thinking（複雑な問題の構造化思考）
claude mcp add sequential-thinking --scope user -- npx -y @modelcontextprotocol/server-sequential-thinking

# GitHub（オプション、GITHUB_TOKEN が必要）
claude mcp add github --scope user -e GITHUB_PERSONAL_ACCESS_TOKEN='${GITHUB_TOKEN}' -- npx -y @modelcontextprotocol/server-github
```

> **Note**: Web コンテンツ取得には Claude Code 組み込みの Fetch/WebFetch ツールを使用します（MCP 不要）。

確認: `claude mcp list`

## 含まれる設定

### ルール（rules/）

パス指定による条件付きルール。該当ファイル編集時のみ適用。

| ルール | 対象パス | 内容 |
|--------|---------|------|
| `typescript.md` | `**/*.ts`, `**/*.tsx` | TypeScript 規約 |
| `python.md` | `**/*.py` | Python 規約 |
| `react.md` | `**/*.tsx`, `**/components/**` | React 規約 |
| `testing.md` | `**/*.test.*`, `**/tests/**` | テスト規約 |
| `security.md` | 全ファイル | セキュリティチェックリスト |

### スキル（skills/）

自動発動するタスク専門スキル。Claude が必要と判断した時に読み込まれる。

| スキル | 発動トリガー例 |
|--------|---------------|
| `commit-message` | 「コミットして」「commit」 |
| `pr-description` | 「PR作成」「プルリクエスト」 |
| `code-review` | 「レビュー」「コードチェック」 |
| `refactoring` | 「リファクタ」「整理」 |
| `test-generation` | 「テスト書いて」「テスト追加」 |
| `planning` | 「計画」「設計」 |
| `documentation` | 「ドキュメント」「README」 |

### コマンド（commands/）

手動実行のショートカット。

| コマンド | 説明 |
|----------|------|
| `/quick-commit` | 小さな変更を確認なしでコミット |
| `/gh-issue` | GitHub Issue を分析して修正 |

### サブエージェント（agents/）

並列実行・権限制限が必要な場合に使用。

| エージェント | 用途 |
|--------------|------|
| `researcher` | 読み取り専用の調査・分析 |
| `implementer` | 計画に基づく実装 |
| `error-investigator` | 試行錯誤を伴うエラー調査 |

### テンプレート

| テンプレート | 用途 | MCP サーバー |
|--------------|------|-------------|
| `minimal` | 最小限の設定 | なし |
| `typescript-web` | TypeScript + React | Playwright（E2E テスト） |
| `python-data` | Python データ分析 | Jupyter |

テンプレートの `.mcp.json` はプロジェクトスコープで自動読み込みされます。

プロジェクト固有の `CLAUDE.md` を作成する際は **[templates/GUIDE.md](templates/GUIDE.md)** を参照してください。

## 推奨ツールチェーン（2025年）

この設定は以下のツールチェーンを前提としています:

| カテゴリ | ツール |
|---------|--------|
| JS/TS フォーマッター | **Prettier**（`.prettierrc` 必須） |
| Python パッケージ | **uv** |
| Python リンター/フォーマッター | **ruff** |
| ランタイムバージョン管理 | **mise** |
| シェル | **Fish** |

## 設計哲学

> **ユーザーレベルは「賢いデフォルト」、プロジェクトレベルは「具体的なオーバーライド」**

- **ユーザーレベル**: 汎用的なワークフロー、言語共通のベストプラクティス
- **プロジェクトレベル**: プロジェクト固有のビルドコマンド、アーキテクチャ、ドメイン知識

## カスタマイズ

設定変更は `home/` 以下のファイルを直接編集し、通常の Git ワークフローで管理。

シンボリックリンク方式のため、`claude config` での GUI 変更も自動的に Git 管理対象になる。

## 注意事項

- `settings.json` の `"Skill"` 許可がないと Skill が発火しない
- MCP サーバーは `claude mcp add` コマンドで管理（設定ファイル直接編集ではない）
- Fish shell では zsh/bash のコマンドがそのまま動かない場合があるので注意
- 個人固有のプロジェクト設定は `CLAUDE.local.md` に分離（自動で gitignore）
