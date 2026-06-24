# claude-config

Claude Code のグローバル設定ディレクトリ `~/.claude` を Git 管理するためのリポジトリ。

**28 スキル・Cursor/Claude/Codex 向けエージェント・9 フック・複数ハーネス向けルール** を統合し、3 つの設計原則で全体を設計しています。

- **Progressive Disclosure** — 必要な情報を必要な時に（CLAUDE.md は 27 行）
- **最小権限と関心の分離** — 10 エージェント中 8 エージェントが指示レベルで読み取り専用
- **重層防御** — deny / ask / hooks / rules の 4 層で安全を確保

## 概要

新しいマシンでも `git clone` + `install.sh` で同一の Claude Code 環境を再現可能。

## 構成

```
claude-config/
├── home/                    # $HOME をルートとしたミラー
│   ├── .shared/             # Claude Code / Codex CLI 両方で参照される共通資産
│   │   ├── hooks/lib/       # secret_patterns / blocked_dirs 等の共通 lib
│   │   └── skills/          # harness 非依存の skill 本体・reference（両側から symlink）
│   ├── .agents/
│   │   └── skills/          # Codex / Agents 用スキル（harness 固有部分のみ。共通分は .shared/skills へリンク）
│   ├── .cursor/
│   │   ├── agents/          # Cursor-native subagents
│   │   ├── cli-config.json  # Cursor CLI グローバル設定
│   │   ├── mcp.json         # Cursor MCP サーバー設定
│   │   └── skills/          # install.sh では .agents/skills へリンク
│   └── .claude/
│       ├── CLAUDE.md       # グローバルユーザー設定
│       ├── settings.json   # 権限・フック設定
│       ├── statusline.js   # ステータスライン表示カスタマイズ
│       ├── rules/          # 条件付きルール（パス指定可能）
│       ├── skills/         # スキル（/コマンド + 自動発動。共通分は .shared/skills へリンク）
│       ├── hooks/          # フック（セキュリティ検証等）
│       │   └── lib/        # Claude 固有 lib（共通 lib は ~/.shared/ から source）
│       └── agents/         # サブエージェント（並列実行用）
├── templates/               # プロジェクト用テンプレート
│   ├── GUIDE.md            # プロジェクト CLAUDE.md 作成ガイド
│   ├── minimal/            # 最小限の設定
│   ├── typescript-web/     # TypeScript + React（Playwright MCP 付き）
│   ├── python-data/        # Python データ分析（Jupyter MCP 付き）
│   └── project-skills/     # プロジェクト用スキルテンプレート
├── bin/
│   ├── check-cursor-config.sh
│   ├── check-skill-drift.sh
│   └── install.sh          # デプロイスクリプト
├── .cursor/
│   └── rules/              # この repo 用 Cursor Project Rules
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

# Codex config.toml の生成・merge のみ実行
./bin/install.sh --codex-config-only

# Cursor 設定のみリンク
./bin/install.sh --cursor-only

# Cursor セットアップをスキップ
./bin/install.sh --no-cursor

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

### Cursor MCP

Cursor 用 MCP は `home/.cursor/mcp.json` で管理します。

- `context7`: 最新ドキュメント取得
- `sequential-thinking`: 複雑な問題の構造化
- `github`: GitHub MCP（`GITHUB_TOKEN` を `${env:GITHUB_TOKEN}` で参照）

Cursor は `.cursor/mcp.json` または `~/.cursor/mcp.json` を読み込み、MCP tool は Run Mode / approval に従います。秘密値は repo に書かず、環境変数で渡します。

## 含まれる設定

### フック（hooks/）

セキュリティ検証・自動化用のフックスクリプト。

| フック                      | トリガー                  | 用途                                                            | async |
| --------------------------- | ------------------------- | --------------------------------------------------------------- | ----- |
| `session-start.sh`          | SessionStart              | `CLAUDE_CODE_TMPDIR` 作成、ツール確認、Git/ランタイム情報表示   | -     |
| `validate-project-scope.sh` | PreToolUse (Bash)         | プロジェクト外への書き込みをブロック                            | -     |
| `context-guard.sh`          | PreToolUse (Read\|Glob)   | node_modules 等の読み込みをブロック                             | -     |
| `post-edit-lint.sh`         | PostToolUse (Edit\|Write) | 編集後の自動フォーマット（format のみ）                         | -     |
| `post-stop-lint.sh`         | Stop                      | タスク完了後の lint auto-fix                                    | -     |
| `pre-compact.sh`            | PreCompact                | コンパクション前に作業状態をコンテキスト保存                    | -     |
| `cwd-changed.sh`            | CwdChanged                | `/cd` 後の mise 環境を `CLAUDE_ENV_FILE` 経由で後続 Bash に反映 | -     |
| `notify-completion.sh`      | Stop                      | セッション完了通知                                              | Yes   |
| `notify-input-required.sh`  | Notification              | 入力必要時通知                                                  | Yes   |

### ルール（rules/）

パス指定による条件付きルール。該当ファイル編集時のみ適用。

| ルール          | 対象パス                                                                  | 内容                                 |
| --------------- | ------------------------------------------------------------------------- | ------------------------------------ |
| `typescript.md` | `**/*.ts`, `**/*.tsx`                                                     | TypeScript 規約                      |
| `python.md`     | `**/*.py`                                                                 | Python 規約                          |
| `react.md`      | `**/*.{tsx,jsx}`, `**/components/**`, `**/hooks/**`                       | React 規約                           |
| `testing.md`    | `**/*.{test,spec}.*`, `**/tests/**`, `**/__tests__/**`, `**/*_test.py` 等 | テスト規約                           |
| `security.md`   | 全ファイル（`**/*`）                                                      | セキュリティチェックリスト           |
| `git.md`        | 全ファイル（`**/*`）                                                      | ブランチ保護、マージ戦略、Scope 規約 |

### スキル（skills/）

すべてのスキルは `/skill-name` で手動実行可能。一部は Claude が自動で呼び出す。

Skill の配置は 3 層構成。

- `home/.shared/skills/` — harness 非依存の本体・reference（両側から相対 symlink で共有）
- `home/.claude/skills/` — Claude Code 固有部分。共通分は `../../.shared/skills/...` へ symlink
- `home/.agents/skills/` — Codex / Agents 固有部分（`AskUserQuestion` / `Task` / `Agent` を Codex の会話確認・`spawn_agent`・`apply_patch` に読み替え）。共通分は同じく symlink
- `~/.cursor/skills/` — `install.sh` が `home/.agents/skills` へリンク。Cursor は `.agents/skills` / `.cursor/skills` / `~/.agents/skills` / `~/.cursor/skills` を読むため、実体は共有してドリフトを避ける。

`codex-delegate` は Claude→Codex 橋渡し skill のため Codex 側には置かない。共通ルールは `home/.agents/skills/CODEX_COMPATIBILITY.md` を参照。

ドリフト確認:

```bash
bin/check-skill-drift.sh
bin/check-cursor-config.sh
```

`.shared/skills/` 配下は `.prettierignore` 対象（フォーマッタが内容を書き換えてドリフトが発生するのを防ぐ）。

以下の表は Claude Code 側の挙動を基準に記載。Codex / Agents 側は `home/.agents/skills/CODEX_COMPATIBILITY.md` のルールに従い、`git commit` / `gh pr create` / `gh pr review` 等の破壊・公開操作はすべて明示的なユーザー確認後に実行する（`/quick-commit` も Codex では確認必須）。

#### 手動実行専用（/コマンド）

| スキル                  | 説明                                                       |
| ----------------------- | ---------------------------------------------------------- |
| `/quick-commit`         | 小さな変更をコミット（Claude: 確認なし / Codex: 確認必須） |
| `/smart-commit`         | 変更を論理的に分割して複数コミット                         |
| `/switch-branch`        | Conventional Branch形式でブランチ作成                      |
| `/gh-pr-create`         | Push済みの変更からPR作成（会話コンテキスト活用）           |
| `/gh-issue-fix`         | GitHub Issue を分析して修正                                |
| `/security-review`      | OWASP Top 10 に基づくセキュリティレビュー                  |
| `/workflow-implement`   | 実装ワークフロー（計画→実装→テスト→レビュー）              |
| `/workflow-fix-bug`     | バグ修正ワークフロー（調査→修正→検証）                     |
| `/workflow-refactoring` | リファクタリングワークフロー                               |
| `/workflow-research`    | 調査ワークフロー（コードベース+Web）                       |
| `/workflow-tdd`         | TDDワークフロー（RED→GREEN→REFACTOR）                      |
| `/handoff`              | セッション進捗まとめ・引継ぎ                               |

#### 自動発動（Claude が判断）

| スキル                    | 発動トリガー例                                                                                             |
| ------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `code-review`             | 「レビュー」「コードチェック」                                                                             |
| `refactoring`             | 「リファクタ」「整理」                                                                                     |
| `test-generation`         | 「テスト書いて」「テスト追加」                                                                             |
| `playwright-test`         | 「Playwright」「E2E」「playwright.config」                                                                 |
| `planning`                | 「計画」「設計」                                                                                           |
| `documentation`           | 「ドキュメント」「README」                                                                                 |
| `web-research`            | 「調べて」「research」「比較」                                                                             |
| `gh-pr-review`            | 「PRレビュー」「PR見て」                                                                                   |
| `ask-claude-code`         | 「Claude Code の使い方」「API の仕様」                                                                     |
| `api-test`                | 「API」「curl」「エンドポイント」                                                                          |
| `mermaid-generation`      | 「Mermaid」「ダイアグラム」「クラス図」                                                                    |
| `skill-creation`          | 「スキル作成」「create skill」                                                                             |
| `empirical-prompt-tuning` | 「プロンプト改善」「スキル評価」「反復改善」                                                               |
| `codex-delegate`          | 「Codex に聞いて」「セカンドオピニオン」「別視点でレビュー」「Codex で調査」「rescue」（Claude Code のみ） |

#### 内部スキル（他スキルから呼び出し）

| スキル           | 用途                                      |
| ---------------- | ----------------------------------------- |
| `commit-message` | Conventional Commits 形式のメッセージ生成 |
| `mcp-guidance`   | MCP サーバーの選択ガイダンス              |

### サブエージェント（agents/）

並列実行・権限制限が必要な場合に使用。全エージェントが `memory: user` でセッション跨ぎの学習を行う。

> **Note**: `memory: user` は Write/Edit を自動追加するため、ツールレベルでは全エージェントが書き込み可能。
> 8 エージェントは `tools:` allowlist でプロジェクトファイル編集用ツールを意図的に除外し、
> エージェント指示で「読み取り専用」として運用している。

| エージェント         | 用途                         | 実装権限 |
| -------------------- | ---------------------------- | -------- |
| `code-researcher`    | 読み取り専用の調査・分析     | 調査のみ |
| `implementer`        | 計画に基づく実装             | 実装可   |
| `error-investigator` | 試行錯誤を伴うエラー調査     | 調査のみ |
| `app-verifier`       | テスト実行・動作検証         | 検証のみ |
| `web-researcher`     | Web情報収集・技術調査        | 調査のみ |
| `security-reviewer`  | セキュリティ脆弱性の検出     | 調査のみ |
| `planner`            | 複雑な機能の実装計画         | 計画のみ |
| `architect`          | システム設計・技術選定       | 設計のみ |
| `log-analyzer`       | ログファイル分析・エラー追跡 | 分析のみ |
| `git-analyst`        | Git 履歴分析・ブランチ戦略   | 分析のみ |

### Cursor Subagents

Cursor 用 subagent は `home/.cursor/agents/` に置きます。`.claude/agents` / `.codex/agents` も互換ディレクトリとして読めますが、同名がある場合は `.cursor/agents` を優先します。

- 読み取り専用系は `readonly: true`
- 実装担当のみ `readonly: false`
- `model: inherit` を使い、親セッションの model 方針を継承
- Claude Code 固有の `tools` / `permissionMode` / `memory` は Cursor frontmatter に持ち込まない

### Cursor Rules

この repo 自体で Cursor を使うための Project Rules は `.cursor/rules/*.mdc` に置きます。

- 常時適用: harness 概要、安全制約
- file-scoped: Git / Python / testing など
- 長い手順は rules に詰め込まず、skills や docs へ分離

### テンプレート

| テンプレート     | 用途               | MCP サーバー             |
| ---------------- | ------------------ | ------------------------ |
| `minimal`        | 最小限の設定       | なし                     |
| `typescript-web` | TypeScript + React | Playwright（E2E テスト） |
| `python-data`    | Python データ分析  | Jupyter                  |

テンプレートの `.mcp.json` はプロジェクトスコープで自動読み込みされます。

### プロジェクト用スキル（project-skills/）

プロジェクト固有の `.claude/skills/` に配置するスキルテンプレート。

| スキル         | 用途                             |
| -------------- | -------------------------------- |
| `agent-memory` | セッション跨ぎの記憶・文脈永続化 |

使用方法:

```bash
cp -r templates/project-skills/agent-memory .claude/skills/
mkdir -p .claude/skills/agent-memory/memories
```

プロジェクト固有の `CLAUDE.md` を作成する際は **[templates/GUIDE.md](templates/GUIDE.md)** を参照してください。

## 推奨ツールチェーン（2026年）

この設定は以下のツールチェーンを前提としています:

| カテゴリ                       | ツール                                             |
| ------------------------------ | -------------------------------------------------- |
| JS/TS フォーマッター           | **Biome**（Primary）、Prettier（MD/YAML/SCSSのみ） |
| Python パッケージ              | **uv**                                             |
| Python リンター/フォーマッター | **ruff**                                           |
| ランタイムバージョン管理       | **mise**                                           |
| シェル                         | **Fish**                                           |

## 設計哲学

> **ユーザーレベルは「賢いデフォルト」、プロジェクトレベルは「具体的なオーバーライド」**

- **ユーザーレベル（`~/.claude/`）**: 汎用的なワークフロー、言語共通のベストプラクティス、全プロジェクト共通のセキュリティ・品質ポリシー
- **プロジェクトレベル（`./.claude/`）**: プロジェクト固有のビルドコマンド、アーキテクチャ、ドメイン知識。`@import` で選択的にルール参照可能

### 3 つの設計原則

| 原則                       | 内容                                                                                                     |
| -------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Progressive Disclosure** | CLAUDE.md（27行）→ rules/ → skills/（→ skills/\*/references/）の 3〜4 層で、必要な情報を必要な時にロード |
| **最小権限と関心の分離**   | settings.json permissions / skills の allowed-tools / agents の tools の 3 スコープで権限を制御          |
| **重層防御**               | deny（絶対禁止）→ ask（都度確認）→ hooks（実行時検証）→ rules（LLM レベルの知識）の 4 層で安全を確保     |

## カスタマイズ

設定変更は `home/` 以下のファイルを直接編集し、通常の Git ワークフローで管理。

シンボリックリンク方式のため、`claude config` での GUI 変更も自動的に Git 管理対象になる。

## 注意事項

- `settings.json` の `"Skill"` 許可がないと Skill が発火しない
- MCP サーバーは `claude mcp add` コマンドで管理（設定ファイル直接編集ではない）
- Fish shell では zsh/bash のコマンドがそのまま動かない場合があるので注意
- 個人固有のプロジェクト設定は `CLAUDE.local.md` に分離（自動で gitignore）
- `settings.json` の `hooks` でセキュリティフックを設定可能（PreToolUse, Stop等）
- `statusLine` 設定で Claude Code 2.1.0+ のステータスライン表示をカスタマイズ可能
