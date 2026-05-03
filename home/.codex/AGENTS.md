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

### Plan files

- Codex には Claude Code の `plansDirectory` 相当の公式設定はない前提で扱う
- 計画を永続化する必要がある場合は、対象プロジェクト内の `.codex/plans/` に Markdown で作成する
- Plan Mode 中は repo-tracked file を作成・編集しない。保存が必要なら、計画確定後に通常実行として作成する
- Claude Code の plan file とは混ぜない。Claude Code 側は `.claude/plans/`、Codex 側は `.codex/plans/` を使う

### Statusline

- Codex の status line は `tui.status_line` の組み込み項目で設定する
- Claude Code の `statusLine.command` のような任意 script 実行型 statusline は Codex 側では前提にしない
- statusline を変える場合は `/statusline` で選べる項目、または公式 config reference にある項目だけを使う

### Claude Code 併用

- 共有してよいもの: skills、hooks の共通 helper、命名規約、計画ファイルの保存先 convention
- 共有しないもの: active runtime state、auth、sessions、cache、Codex-managed `default.rules`
- `~/.codex/config.toml` は app-managed local state を含むため、repo では `config.base.toml` を source of truth とする

### Rules

- `~/.codex/rules/` の Starlark rules（`security` / `git` / `package-manager` / `filesystem`）を遵守する
- `approval_policy = "on-request"` + `sandbox_mode = "workspace-write"` を前提とする

### Allow policy

- allow: read-only inspection、version check、syntax check、`codex features list`、`codex execpolicy check`
- prompt: test/build、dependency install、`mkdir` / `mv` / `rm`、Docker 実行系、`gh api`、`git commit` / `push` / `merge` / `rebase`
- forbid: force push、credential/secret 操作、`sudo` / `su`、`curl | sh`、root/home への recursive delete、認証状態変更
- allow を増やす場合は `prefix_rule` だけで判断せず、変形コマンドを hook と `codex execpolicy check` で検証する
