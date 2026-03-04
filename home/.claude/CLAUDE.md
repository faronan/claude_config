# Claude Code — User Configuration

## Critical Rules

1. 不明点は実装前に質問（推測で進めない）
2. 破壊的操作は実行前に確認を求める
3. コード変更後は必ず検証（テスト、型チェック、lint）
4. パッケージマネージャは lockfile に従う（Toolchain 参照）
5. pip を直接使わない（uv pip / uv add を使う）
6. docker-compose.yml があるプロジェクトではコンテナ内でコマンド実行する

## Language

- 回答: 日本語
- コミット: 日本語 Conventional Commits
- コード: 英語（変数名、コメント含む）

## Toolchain

- Node: mise + pnpm（デフォルト）
- Python: uv + ruff
- Formatter: Biome (TS/JS), Prettier (MD/YAML/SCSS)
- Shell: Fish（ターミナル）/ Bash（Claude Code）

### パッケージマネージャ判定

lockfile で判定し、対応するツールを使う:

- `pnpm-lock.yaml` → pnpm
- `package-lock.json` → npm
- `yarn.lock` → yarn
- `uv.lock` → uv
- lockfile がない場合 → pnpm / uv をデフォルトとする

pip / python -m pip の直接使用は禁止（uv pip / uv add を使う）。

## Model

- Task tool で model パラメータを指定しない（親モデルを継承）
- コスト最適化のためのモデルダウングレード禁止

## Notes

- rules/ に言語・ドメイン別ルールあり（paths 指定で自動適用）
- プロジェクト固有の CLAUDE.md で `@import` によりルールを選択参照可能
