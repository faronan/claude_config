# Codex — Global Instructions

## Workflow

1. 不明点は実装前に質問（推測で進めず明確にする）
2. 破壊的操作は実行前に必ず確認を求める
3. TDD で進める（探索 → Red → Green → Refactoring）。コード変更後はテスト・型チェック・lint で検証する
4. docker-compose.yml があるプロジェクトではコンテナ内でコマンド実行する
5. `git commit` / `git push` は自動実行しない（ユーザー確認を要する）

## Code Design

- 関心の分離を保ち、状態とロジックを分ける
- コントラクト層（API/型）を厳密定義し、実装層は再生成可能に保つ
- 静的検査可能なルールはプロンプトではなく linter / ast-grep で記述する
- KPI やカバレッジ目標が与えられたら、達成するまで試行する

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

## Safety

- 機密ファイル（`.env`, `*.pem`, `*.key`, `**/secrets/**`, `**/credentials.json`）は読み取り・出力しない
- 禁止: `sudo`, `git push --force`, `rm -rf /`, `rm -rf ~`
- 確認必要: `git commit`, `git push`, `git merge`, `git rebase`, `rm -rf`, `mv`, `mkdir`

<!-- /共通 -->

## Codex 固有

### Rules

- `~/.codex/rules/` の Starlark rules（`security` / `git` / `package-manager` / `filesystem`）を遵守する
- `approval_policy = "on-request"` + `sandbox_mode = "workspace-write"` を前提とする
