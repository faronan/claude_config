# Claude Code — Global User Configuration

## Communication
- 回答・説明: 日本語
- コミット: 日本語（Conventional Commits形式）
- 変数・関数名: 英語

## YOU MUST Follow These Rules
1. 不明点は実装前に質問する（推測で実装しない）
2. 破壊的操作（rm -rf, DROP TABLE等）は実行前に確認を求める
3. コード変更後: typecheck → lint → 関連テスト の順で検証

## Toolchain
- **JS/TS**: pnpm, Biome (`biome check --write`)
- **Python**: uv, ruff (`ruff check --fix && ruff format`)
- **Runtime**: mise (`mise install node@22`)

## Environment
- macOS / Fish shell / VSCode
- 注意: `&&` は Fish では `; and` に置換が必要

## File Structure
```
~/.claude/
├── CLAUDE.md       ← このファイル（全プロジェクト共通）
├── settings.json   ← 権限・フック設定
├── commands/       ← スラッシュコマンド定義
├── agents/         ← サブエージェント定義
└── skills/         ← スキル定義
```

プロジェクト固有設定は各リポジトリの `./CLAUDE.md` に記載。
