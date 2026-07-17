# Codex — User Configuration

This file is user-level guidance for Codex. Project-specific instructions belong
in the target repository's `AGENTS.md`.

## Workflow

1. 不明点は実装前に質問（推測で進めず明確にする）
2. 破壊的操作は実行前に必ず確認を求める
3. TDD で進める（探索 → Red → Green → Refactoring）
4. コード変更後は関連する test / typecheck / lint を実行し、未実行なら理由を明記する
5. docker-compose.yml があるプロジェクトではコンテナ内でコマンド実行する
6. `git commit` / `git push` は自動実行しない（ユーザー確認を要する）

### Blocked / Unavailable Commands

- 必要な探索・実装・検証コマンドが sandbox、rules/hooks、PATH、
  未インストール tool、権限、network、session/tooling 不調で実行できない場合は、
  推測で代替 path や別コマンドを探して進めない。
- 検証を諦めたり、勝手に scope を下げたり、rules/hooks/sandbox の deny/forbid を
  sandbox 外実行や等価な代替手段で迂回したりしない。
- 一度停止し、実行したかった正確なコマンド、`cwd`、失敗理由、
  必要な判断を短く報告する。
- ユーザーがローカルで実行できる可能性がある場合は、実行してほしいコマンドを
  そのまま提示し、結果を待ってから判断に反映する。
- sandbox 外実行、network、dependency install、Docker 実行が必要な場合は、
  必要性と対象コマンドを明示して確認を取る。
- `git commit` は、ユーザーが明示的に依頼し、staged diff を確認した後に限り実行する。
  Codex の Workspace permission でも `.git` は保護対象になり得るため、sandbox 内で
  `git commit` を試さない。必要な commit コマンド、`cwd`、理由を示して承認付き
  sandbox 外実行を申請する。承認付き実行できない場合は、通常 terminal で実行する
  exact command を提示して結果を待つ。
  この扱いを `git add`、`git push`、`git merge`、`git rebase`、その他の Git 操作へ広げない。

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
- Shell: Fish（対話ターミナル）; hooks/scripts は POSIX shell / Bash 前提

### パッケージマネージャ判定

lockfile で判定し、対応するツールを使う:

- `pnpm-lock.yaml` → pnpm
- `package-lock.json` → npm
- `yarn.lock` → yarn
- `uv.lock` → uv
- lockfile がない場合 → pnpm / uv をデフォルトとする

## Safety

- 機密ファイルは読み取り・出力しない
- 対象例: `.env`, `*.pem`, `*.key`, `**/secrets/**`, `**/credentials.json`,
  `**/.ssh/**`, `**/.aws/**`, `**/.kube/**`, `**/.npmrc`, `**/.pypirc`,
  `**/*service-account*.json`, `**/*service_account*.json`, `**/*.kubeconfig`
- GitHub CLI の認証設定 (`~/.config/gh/hosts.yml`) は `gh` 実行時の内部読み取りだけ許容し、
  明示的に読み取ったり出力したりしない
- 禁止: `sudo`, `su`, `git push --force`, `git push -f`, `rm -rf /`, `rm -rf ~`
- 確認必要: `git commit`, `git push`, `git merge`, `git rebase`, `git stash`,
  `rm -rf`, `mv`, `mkdir`, dependency install, Docker 実行系

## Model / Agents

- 直接起動する Agent tool では model パラメータを指定せず、親モデルを継承する
- custom agent TOML に明示された `model` / `model_reasoning_effort` は、その agent 定義として尊重する
- コスト最適化のためのモデルダウングレード禁止
- subagent は具体的で分離可能な作業だけに使い、実装時は担当ファイルを明確にする

## Context / Compaction

コンパクション時に以下を必ず保持すること:

- 現在のタスクの目標と進捗状況
- 変更済みファイルの一覧とその変更内容の要約
- 実行したテストコマンドとその結果
- 未解決の問題や次のステップ
- ユーザーからの重要な指示や制約

## Skill Management

- **project固有** (`<repo>/.agents/skills/`): ドメイン知識・規約・ファイルレイアウト依存、他 repo で再利用しない
- **ユーザー共通** (`$HOME/.agents/skills/`): 言語・ツール横断、複数 repo で再利用可能
- ユーザー共通 skill を新規作成・大幅変更する場合はユーザーに確認する
- 長い手順や詳細な知識は `AGENTS.md` に詰め込まず、skills / hooks / rules に分離する

<!-- /共通 -->

## Codex 固有

### Instruction files

- `~/.codex/AGENTS.md` はユーザーレベルの既定指示として扱う
- project-level の指示は対象 repo の `AGENTS.md` に置く
- 一時的な上書きが必要な場合は `AGENTS.override.md` を使い、恒久化しない
- instruction file の変更は既存 session に自動反映されないため、新規 session / restart で確認する
- instruction は小さく保つ。詳細は必要な時に読む skills / docs / rules へ分離する

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
- この設定 repo では `~/.codex/config.toml` は app-managed local state を含む active file として扱い、repo では `config.base.toml` を source of truth とする
- `projects`、`marketplaces`、`plugins`、`hooks.state`、`tui.model_availability_nux`、`notice`、`desktop`、repo 管理外の MCP は install 時に local state として温存する
- `context7` と `sequential-thinking` だけは repo 管理の MCP とし、base config の定義を優先する

### Rules / Allow policy

- 現在の `approval_policy` / `default_permissions` / `[permissions]` / `~/.codex/rules/` に従う
- 詳細な allow / prompt / forbid は `config.base.toml`、`.rules`、hooks を source of truth とする
- `default.rules` は Codex-managed local state として扱い、Git 管理に入れない
- allow を増やす場合は `prefix_rule` だけで判断せず、変形コマンドを hook と `codex execpolicy check` で検証する
