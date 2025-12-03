# Claude Code — Personal Configuration

## Language & Communication
- 説明・質問への回答: 日本語
- コードコメント: 日本語
- コミットメッセージ: 日本語（Conventional Commits 形式）
- 変数名・関数名: 英語
- ドキュメント: 日本語（技術用語は英語併記可）

## General Preferences
- 不明点は実装前に質問する
- 推測で実装せず、不確かな点は確認する
- 破壊的操作（rm -rf, git reset --hard, DROP TABLE 等）は必ず確認を求める
- アーキテクチャ変更前は計画を提示する

## Coding Standards
- 型安全性を最優先（any/unknown の使用は最小限に）
- エラーは握りつぶさず、適切にハンドリング
- 早期リターンで深いネストを避ける

## Workflow Rules
- コード変更後は typecheck → lint → 関連テスト の順で検証
- 全テスト実行より関連テストを優先
- 20イテレーション程度で /compact を検討

## Tool Preferences

### JavaScript/TypeScript
- パッケージマネージャー: pnpm > npm > yarn
- リンター/フォーマッター:
  - 新規プロジェクト: **Biome**（`biome check --write`）
  - 既存/Vue/Svelte: ESLint + Prettier
- 型チェック: tsc --noEmit

### Python
- パッケージマネージャー: **uv**
  - `uv add` / `uv remove` でパッケージ管理
  - `uv run` でスクリプト実行
  - `pip install` は使わない
- リンター/フォーマッター: **ruff**
  - `ruff check --fix` でリント
  - `ruff format` でフォーマット
  - black, flake8, isort は使わない
- 仮想環境: `uv venv`（python -m venv は使わない）

### バージョン管理
- ランタイム: **mise**
  - `mise install node@22` / `mise install python@3.12`
  - pyenv, nvm, nodenv は使わない

## Environment
- OS: macOS
- Shell: **Fish**（zsh/bash コマンドは Fish 互換に注意）
- Editor: VSCode
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
