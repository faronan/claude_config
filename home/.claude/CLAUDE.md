# Claude Code — User Configuration

## Language
- 回答・説明: 日本語
- コミットメッセージ: 日本語（Conventional Commits）
- コード（変数・関数名）: 英語

## Critical Rules
1. 不明点は実装前に質問（推測で進めない）
2. 破壊的操作は実行前に確認を求める
3. コード変更後は必ず検証を実行（具体的な手順はプロジェクトのCLAUDE.mdを参照）

## Environment
- macOS / Fish shell (`&&` → `; and`)
- Editor: VSCode
- Node: mise, pnpm
- JS/TS Formatter: Prettier（.prettierrc必須）
- Python: uv, ruff

## Context Management
- Skills/Commands は必要時のみ読み込まれる
- 詳細な手順は Skills に記載
- 常に必要な情報のみをここに記載
