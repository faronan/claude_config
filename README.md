# claude-config

Claude Code のグローバル設定ディレクトリ `~/.claude` を Git 管理するためのリポジトリ。

## 概要

新しいマシンでも `git clone` + `install.sh` で同一の Claude Code 環境を再現可能。

## 構成

```
claude-config/
├── home/                    # $HOME をルートとしたミラー
│   ├── .claude/
│   │   ├── CLAUDE.md       # グローバルユーザー設定
│   │   ├── settings.json   # 権限・フック設定
│   │   ├── commands/       # スラッシュコマンド
│   │   ├── agents/         # サブエージェント
│   │   └── skills/         # スキル
│   └── .mcp.json           # MCP サーバー設定
├── templates/               # プロジェクト用テンプレート
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

### 新マシンでの再現

```bash
git clone git@github.com:<username>/claude-config.git ~/claude-config
~/claude-config/bin/install.sh
```

### 環境変数の設定

`.zshrc` 等に以下を追加:

```bash
export GITHUB_TOKEN="ghp_xxxx"  # .mcp.json で参照
```

## 含まれる設定

### スラッシュコマンド

| コマンド | 説明 |
|----------|------|
| `/commit` | ステージ済み変更からコミットメッセージを生成 |
| `/pr` | PR 説明文を生成 |
| `/review` | コードレビューを実行 |
| `/plan` | タスクの実行計画を策定 |

### サブエージェント

| エージェント | 説明 |
|--------------|------|
| `@code-reviewer` | コードレビュー専門 |
| `@explainer` | コード説明専門 |

### テンプレート

| テンプレート | 用途 |
|--------------|------|
| `minimal` | 最小限の設定 |
| `typescript-web` | TypeScript + React プロジェクト |

## カスタマイズ

設定変更は `home/` 以下のファイルを直接編集し、通常の Git ワークフローで管理。

シンボリックリンク方式のため、`claude config` での GUI 変更も自動的に Git 管理対象になる。

## 注意事項

- `settings.json` の `"Skill"` 許可がないと Skill が発火しない
- `.mcp.json` にシークレットを直接書かない（`${ENV_VAR}` 形式を使用）
