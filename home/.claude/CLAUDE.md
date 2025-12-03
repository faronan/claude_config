# Claude Code — Personal Configuration

## Language & Communication
- 説明・質問への回答: 日本語
- コードコメント: 英語
- コミットメッセージ: 日本語（Conventional Commits 形式）
- 変数名・関数名: 英語

## General Preferences
- 不明点は実装前に質問する
- 破壊的操作（rm, reset --hard 等）は必ず確認を求める
- アーキテクチャ変更前は計画を提示する

## Coding Standards
- 型安全性を最優先
- エラーハンドリングを徹底
- 関数は単一責任の原則に従う
- マジックナンバーは定数化

## Workflow Rules
- コード変更後は必ず typecheck/lint を実行
- 全テストではなく関連テストのみを実行
- 20イテレーション程度で /compact を検討

## Tool Preferences
- パッケージマネージャー: pnpm > npm > yarn
- フォーマッター: prettier（JS/TS）、black（Python）
- リンター: eslint（JS/TS）、ruff（Python）
- エディタ: VSCode

## Environment
- OS: macOS
- 主な開発言語: TypeScript, Python

## SubAgent Usage Rules
以下の条件で対応するサブエージェントを**必ず**使用すること：

| 条件 | サブエージェント |
|------|------------------|
| コードレビュー依頼 | @code-reviewer |
| コード説明依頼 | @explainer |
| セキュリティレビュー | @security-reviewer |
| パフォーマンス分析 | @performance-analyzer |
| リファクタリング提案 | @refactoring-advisor |

## Skill Usage Rules
以下の条件で対応するスキルを参照すること：

| 条件 | スキル |
|------|--------|
| コミットメッセージ生成 | commit-message |
| PR説明文生成 | pr-description |
| ドキュメント生成 | documentation-style |

## References
詳細は以下を参照:
- @docs/architecture.md - システム設計
- @docs/coding-standards.md - コーディング規約詳細
