# プロジェクト CLAUDE.md 作成ガイド

プロジェクト固有の `./CLAUDE.md` を効果的に作成するためのガイド。

---

## TL;DR チェックリスト

新しいプロジェクトで CLAUDE.md を作成する際:

- [ ] プロジェクト概要を1-2文で記載
- [ ] 主要コマンド（dev, test, build）を記載
- [ ] ディレクトリ構造の概要を記載
- [ ] 60行以下に収まっている
- [ ] グローバル設定（`~/.claude/CLAUDE.md`）と重複していない
- [ ] 機密情報が含まれていない
- [ ] コードフォーマット規則はリンターに委任している

---

## 1. CLAUDE.md の書き方

### 基本原則

| 原則 | 内容 |
|------|------|
| **簡潔さ** | 60行以下（理想は30-40行）。全セッションで読み込まれるためトークン効率が重要 |
| **WHAT** | 技術スタック、構造（例: React + TypeScript、モノレポ構成） |
| **WHY** | プロジェクトの目的（例: ECサイトのバックエンド） |
| **HOW** | 開発・検証方法（例: `pnpm test`、`docker compose up`） |

### 含めるべき内容

**✅ 必須:**
```markdown
## Project Overview
[1-2文でプロジェクトの目的を説明]

## Commands
- `pnpm dev` - 開発サーバー
- `pnpm test` - テスト実行
- `pnpm build` - ビルド

## Architecture
- `src/` - メインコード
- `tests/` - テスト
```

**✅ 推奨（必要に応じて）:**
```markdown
## Key Files
- `src/config.ts` - 設定管理

## Conventions
- コンポーネントは PascalCase
```

### 含めるべきでない内容

| 内容 | 理由 | 代替手段 |
|------|------|----------|
| コードフォーマット規則 | リンターに任せる | Biome/ESLint 設定 |
| 詳細な型定義ルール | TSConfig で強制 | `tsconfig.json` |
| 全コマンドの網羅 | 情報過多 | 頻用コマンドのみ |
| タスク固有の指示 | 普遍的でない | 会話で指示 |
| 機密情報 | セキュリティリスク | `.env`、Secrets Manager |

### 強調キーワード

アドヒアランス（遵守率）を向上させるキーワード:

```markdown
## IMPORTANT
- [強調したい事項]

## NEVER
- [絶対にやってはいけないこと]
```

**効果**: Arize社の研究で5-10%の性能向上が確認されている

---

## 2. 設定ファイル体系

### ファイル階層

```
~/.claude/                    # ユーザーレベル（グローバル）
├── CLAUDE.md                 # 言語設定、個人の好み
├── settings.json             # 共通の権限・環境変数
└── settings.local.json       # 個人的な権限（gitignore対象）

./                            # プロジェクトレベル
├── CLAUDE.md                 # リポジトリ固有の情報
├── CLAUDE.local.md           # 個人的な作業メモ（gitignore対象）
├── .mcp.json                 # プロジェクト固有MCP
└── .claude/
    ├── settings.json         # プロジェクト設定（チーム共有）
    └── settings.local.json   # 個人設定（gitignore対象）
```

### settings.json の主要設定

```json
{
  "env": {
    "CLAUDE_CODE_TASK_LIST_ID": "my-project"
  },
  "plansDirectory": ".claude/plans",
  "disabledMcpjsonServers": ["playwright"],
  "permissions": {
    "allow": ["Read", "Write", "Bash(pnpm:*)"],
    "deny": ["Bash(rm -rf:*)"]
  }
}
```

| 設定 | 説明 |
|------|------|
| `CLAUDE_CODE_TASK_LIST_ID` | タスクリストの識別子。セッション間で共有される |
| `plansDirectory` | プランファイルの保存場所（コミット可能） |
| `disabledMcpjsonServers` | 無効化するMCPサーバー |
| `permissions` | ツールの許可/拒否ルール |

### 個人用オーバーライド

チーム共有設定を個人的にカスタマイズする場合:

| 共有ファイル | 個人用ファイル |
|-------------|---------------|
| `CLAUDE.md` | `CLAUDE.local.md` |
| `.claude/settings.json` | `.claude/settings.local.json` |

**両方のファイルが存在する場合、マージされます。**

**CLAUDE.local.md の例:**
```markdown
# Personal Settings

## 作業スタイル
- コード変更前に計画を見せてほしい
- 説明は日本語で詳しく

## 現在のフォーカス
- [ ] 認証機能のリファクタリング
```

**settings.local.json の例:**
```json
{
  "permissions": {
    "allow": ["Bash(lazygit:*)"]
  },
  "env": {
    "EDITOR": "cursor"
  }
}
```

### 実験的機能: エージェントチーム

複数のエージェントを並列で起動し、調査・レビュー等を協調実行できる。有効化はプロジェクトの `settings.local.json` で行う（VCS非共有）:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

| 項目 | 内容 |
|------|------|
| ステータス | Research Preview（実験的） |
| トークン消費 | 単一セッションより大幅に増加 |
| 推奨ユースケース | 並列コードレビュー、複数仮説の同時検証、大規模調査 |
| 設定場所 | プロジェクトの `settings.local.json`（必要なプロジェクトのみ） |

---

## 3. MCP 管理

### 推奨ガイドライン

| 項目 | 推奨値 | 理由 |
|------|--------|------|
| 有効MCP数 | **10個以下** | ツール選択の混乱を防ぐ |
| 総ツール数 | **80個以下** | プロンプトサイズの最適化 |

### 設定方法

| 目的 | ファイル | 設定 |
|------|---------|------|
| MCP追加 | `.mcp.json` | `mcpServers` に定義 |
| MCP無効化 | `settings.json` | `disabledMcpjsonServers` |

**プロジェクトにMCPを追加（.mcp.json）:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic/mcp-playwright"]
    }
  }
}
```

**ユースケース別の推奨MCP:**

| プロジェクトタイプ | 有効にするMCP |
|------------------|--------------|
| Web開発 | context7, playwright |
| API開発 | context7, github |
| データ分析 | context7, sequential-thinking |

---

## 4. 大規模プロジェクト向け

### Progressive Disclosure（段階的開示）

詳細を別ファイルに分離:

```markdown
## Documentation
詳細は以下を参照:
- `docs/architecture.md` - システム設計
- `docs/api.md` - API仕様
```

**ディレクトリ別 CLAUDE.md:**
```
project/
├── CLAUDE.md           # プロジェクト全体
├── src/
│   └── CLAUDE.md       # src固有のコンテキスト
└── tests/
    └── CLAUDE.md       # テスト固有のコンテキスト
```

### @ インポート（ファイル直接参照）

`@path/to/file` 構文で重要ファイルを常に読み込み:

```markdown
## References
- @README.md
- @docs/api.md
```

| 記法 | 用途 |
|------|------|
| `@file.md` | 常に読み込む重要ファイル |
| `詳細は dir/ を参照` | 必要に応じて探索 |

**注意**: @ インポートはトークンを消費するため、本当に必要なファイルのみ指定。

---

## 5. テンプレート選択

| プロジェクトタイプ | テンプレート | 特徴 |
|------------------|-------------|------|
| 最小構成 | `minimal/` | 10行程度、汎用 |
| TypeScript Web | `typescript-web/` | React/Next.js、Playwright MCP |
| Python データ分析 | `python-data/` | Jupyter、pandas/numpy |

---

## 参考リンク

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Anthropic公式
- [Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) - HumanLayer
- [CLAUDE.md Optimization](https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/) - Arize
