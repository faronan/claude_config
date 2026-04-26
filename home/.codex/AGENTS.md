# Codex — Global Instructions

## Workflow

- 実装前に必ず計画を確認し、不明点は質問してから進める
- TDD: 探索 → Red → Green → Refactoring の順で進める
- コード変更後は lint / フォーマッタを実行する
- `git commit` / `git push` は自動実行しない（ユーザー確認を要する）
- 破壊的操作は実行前に必ず確認を求める

## Coding Conventions

- コード（変数名・コメント含む）は英語
- コミットメッセージは日本語 Conventional Commits
- Node: mise + pnpm / Python: uv + ruff
- Formatter: Biome (TS/JS), Prettier (MD/YAML/SCSS)
- pip / python -m pip 直接使用禁止（uv pip / uv add を使う）
- lockfile で判定: `pnpm-lock.yaml` → pnpm, `package-lock.json` → npm, `uv.lock` → uv

## Rules

- `~/.codex/rules/` の Starlark rules を遵守する
- 禁止: `sudo`, `git push --force`, `rm -rf /`, `rm -rf ~`
- 確認必要: `git commit`, `git push`, `git merge`, `git rebase`, `rm -rf`, `mv`, `mkdir`

## Safety

- docker-compose.yml があるプロジェクトではコンテナ内でコマンド実行する
- 機密ファイル（`.env`, `*.pem`, `*.key`）は読み取り・出力しない
