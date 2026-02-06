# Claude Code — User Configuration

## Critical Rules（最重要）
1. 不明点は実装前に質問（推測で進めない）
2. 破壊的操作は実行前に確認を求める
3. コード変更後は必ず検証を実行

## Language
- 回答: 日本語 (settings.json: japanese)
- コミット: 日本語 Conventional Commits
- コード: 英語

## Environment
- Shell: Fish（ターミナル）/ Bash（Claude Code）
- Editor: VSCode
- Node: mise, pnpm
- Python: uv, ruff
- Formatter: Biome (TS/JS), Prettier (MD/YAML/SCSS)

## Notes
詳細は rules/, skills/, agents/ を参照。
プロジェクト固有の CLAUDE.md では @import で選択的にルールを参照可能。
