# Claude Code — User Configuration

## Critical Rules

1. 不明点は実装前に質問（推測で進めない）
2. 破壊的操作は実行前に確認を求める
3. コード変更後は必ず検証（テスト、型チェック、lint）

## Language

- 回答: 日本語
- コミット: 日本語 Conventional Commits
- コード: 英語（変数名、コメント含む）

## Toolchain

- Node: mise + pnpm
- Python: uv + ruff
- Formatter: Biome (TS/JS), Prettier (MD/YAML/SCSS)
- Shell: Fish（ターミナル）/ Bash（Claude Code）

## Model

- Task tool で model パラメータを指定しない（親モデルを継承）
- コスト最適化のためのモデルダウングレード禁止

## Notes

- rules/ に言語・ドメイン別ルールあり（paths 指定で自動適用）
- プロジェクト固有の CLAUDE.md で `@import` によりルールを選択参照可能
