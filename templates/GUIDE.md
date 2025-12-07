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

---

## 参考リンク

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Anthropic公式
- [Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) - HumanLayer
- [CLAUDE.md Optimization](https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/) - Arize
