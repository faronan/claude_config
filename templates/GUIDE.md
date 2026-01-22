# プロジェクト CLAUDE.md 作成ガイド

プロジェクト固有の `./CLAUDE.md` を効果的に作成するためのガイド。

## 基本原則

### 1. 簡潔さを最優先
- **推奨行数**: 60行以下（理想は30-40行）
- **理由**: CLAUDE.mdは全セッションに読み込まれるため、トークン効率が重要
- **命令数制限**: Claude Codeのシステムプロンプトが約50命令を消費済み。追加は100-150命令が上限

### 2. WHAT・WHY・HOW の3要素
| 要素 | 内容 | 例 |
|------|------|-----|
| **WHAT** | 技術スタック、構造 | React + TypeScript、モノレポ構成 |
| **WHY** | プロジェクトの目的 | ECサイトのバックエンド |
| **HOW** | 開発・検証方法 | `pnpm test`、`docker compose up` |

### 3. グローバル設定との分離
- **グローバル** (`~/.claude/CLAUDE.md`): 言語設定、ツールチェーン、個人の好み
- **プロジェクト** (`./CLAUDE.md`): リポジトリ固有のコマンド、アーキテクチャ、規約

---

## 含めるべき内容

### ✅ 必須
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

### ✅ 推奨（必要に応じて）
```markdown
## Key Files
- `src/config.ts` - 設定管理
- `src/lib/api.ts` - API クライアント

## Conventions
- コンポーネントは PascalCase
- API エンドポイントは /api/v1/ 配下

## Testing
- `pnpm test:unit` - ユニットテスト
- `pnpm test:e2e` - E2Eテスト（Playwright）
```

---

## 含めるべきでない内容

### ❌ 避けるべき
| 内容 | 理由 | 代替手段 |
|------|------|----------|
| コードフォーマット規則 | リンターに任せる | Biome/ESLint設定 |
| 詳細な型定義ルール | TSConfig/Biomeで強制 | `tsconfig.json` |
| 全コマンドの網羅 | 情報過多 | 頻用コマンドのみ |
| タスク固有の指示 | 普遍的でない | 会話で指示 |
| 機密情報 | セキュリティリスク | `.env`、Secrets Manager |

---

## 強調キーワードの活用

アドヒアランス（遵守率）を向上させるキーワード:

```markdown
## YOU MUST Follow These Rules
1. [重要なルール]

## IMPORTANT
- [強調したい事項]

## NEVER
- [絶対にやってはいけないこと]
```

**効果**: Arize社の研究で、強調キーワードにより5-10%の性能向上が確認されている

---

## 個人用オーバーライド（CLAUDE.local.md）

チーム共有設定を個人的にカスタマイズしたい場合:

| 共有ファイル | 個人用ファイル | 用途 |
|-------------|---------------|------|
| `CLAUDE.md` | `CLAUDE.local.md` | 個人的な作業スタイル |
| `.claude/settings.json` | `.claude/settings.local.json` | 個人的な権限・環境変数 |

**両方のファイルが存在する場合、両方が読み込まれマージされます。**

### 作成方法
1. `/memory` コマンド → 「Project memory (local)」を選択
2. または手動で `CLAUDE.local.md` を作成し、`.gitignore` に追加

### CLAUDE.local.md の例

**基本テンプレート:**
```markdown
# Personal Settings

## 個人環境
- Editor: Cursor（チームはVSCode）
- 追加ツール: tmux, lazygit

## 作業スタイル
- コード変更前に必ず計画を見せてほしい
- 詳細な説明を日本語でお願いします
```

**詳細テンプレート（フル機能）:**
```markdown
# CLAUDE.local.md - Personal Development Preferences

## Working Style
- 大きな変更前は計画を確認させてほしい
- コミットは細かく分割して作成

## My Environment
- Terminal: WezTerm + tmux
- Shell: Fish（Claude Code は Bash）
- Git GUI: lazygit

## Communication
- 説明は日本語で詳しくお願いします
- エラー時は原因と対策を両方教えてほしい

## Current Focus
<!-- 現在取り組んでいるタスクをメモ -->
- [ ] 認証機能のリファクタリング
- [ ] テストカバレッジ80%達成
```

### settings.local.json の例

個人的な権限設定やフックのオーバーライド:

```json
{
  "permissions": {
    "allow": [
      "Bash(lazygit:*)"
    ]
  },
  "env": {
    "EDITOR": "cursor"
  }
}
```

---

## Progressive Disclosure（段階的開示）

大規模プロジェクトでは、詳細を別ファイルに分離:

```markdown
## Documentation
詳細は以下を参照:
- `docs/architecture.md` - システム設計
- `docs/api.md` - API仕様
- `docs/testing.md` - テスト戦略
```

**ディレクトリ別CLAUDE.md**:
```
project/
├── CLAUDE.md           # プロジェクト全体
├── src/
│   └── CLAUDE.md       # src固有のコンテキスト
└── tests/
    └── CLAUDE.md       # テスト固有のコンテキスト
```

### @ インポート（ファイル直接参照）

`@path/to/file` 構文で、**常に読み込むべき重要ファイル**を直接参照できます:

```markdown
## References
- Project overview: @README.md
- Available scripts: @package.json
- API documentation: @docs/api.md
```

**使い分け:**

| 記法 | 用途 | 例 |
|------|------|-----|
| `@file.md` | 常に読み込む重要ファイル | `@README.md`, `@docs/api.md` |
| `詳細は dir/ を参照` | 必要に応じて探索するディレクトリ | `詳細は docs/ を参照` |

**注意**: @ インポートはファイルを直接読み込むため、大きなファイルや多数のファイルを参照するとトークンを消費します。本当に毎回必要なファイルのみを指定してください。

---

## テンプレート選択ガイド

| プロジェクトタイプ | テンプレート | 特徴 |
|------------------|-------------|------|
| 最小構成 | `minimal/` | 10行程度、汎用 |
| TypeScript Web | `typescript-web/` | React/Next.js、Playwright MCP |
| Python データ分析 | `python-data/` | Jupyter、pandas/numpy |

---

## チェックリスト

新しいプロジェクトで CLAUDE.md を作成する際:

- [ ] プロジェクト概要を1-2文で記載
- [ ] 主要コマンド（dev, test, build）を記載
- [ ] ディレクトリ構造の概要を記載
- [ ] 60行以下に収まっている
- [ ] グローバル設定と重複していない
- [ ] 機密情報が含まれていない
- [ ] コードフォーマット規則はリンターに委任している
- [ ] 個人固有の設定は `CLAUDE.local.md` に分離している

---

## MCP（Model Context Protocol）管理

### 推奨ガイドライン

| 項目 | 推奨値 | 理由 |
|------|--------|------|
| 有効MCP数 | **10個以下** | ツール選択の混乱を防ぐ |
| 総ツール数 | **80個以下** | プロンプトサイズの最適化 |

### disabledMcpjsonServers の活用（MCP無効化）

`settings.json` で不要なMCPを無効化:
- **グローバル**: `~/.claude/settings.json`
- **プロジェクト**: `.claude/settings.json`

```json
{
  "disabledMcpjsonServers": [
    "playwright",
    "github"
  ]
}
```

**ユースケース別の有効化例:**

| プロジェクトタイプ | 有効にするMCP |
|------------------|--------------|
| Web開発 | context7, playwright |
| API開発 | context7, github |
| データ分析 | context7, sequential-thinking |
| ドキュメント作成 | context7 |

### プロジェクトごとのMCP追加

`.mcp.json`（プロジェクトルート）でMCPを追加:

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

### 設定ファイルの役割整理

| ファイル | 役割 | 用途 |
|---------|------|------|
| `.mcp.json` | MCP**追加** | プロジェクト固有MCPの定義 |
| `settings.json` の `disabledMcpjsonServers` | MCP**無効化** | 不要なMCPの除外 |

### MCP選択のベストプラクティス

1. **必要最小限を有効化**: 使わないMCPは無効にする
2. **プロジェクト固有設定**: グローバルは汎用、プロジェクトで追加
3. **定期的な見直し**: 使用頻度が低いMCPは無効化を検討

### 注意事項

- MCPが多すぎると応答が遅くなる可能性
- 同じ機能を持つMCPは1つに絞る
- 開発中のMCPはプロジェクト単位でのみ有効化

---

## 参考リンク

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Anthropic公式
- [Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) - HumanLayer
- [CLAUDE.md Optimization](https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/) - Arize
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) - ハッカソン優勝設定集
