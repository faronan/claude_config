# Claude Code — User Configuration

## Critical Rules

1. 不明点は実装前に質問（推測で進めず明確にする）
2. 破壊的操作は実行前に確認を求める
3. TDD で進める（探索 → Red → Green → Refactoring）。コード変更後はテスト・型チェック・lint で検証する
4. docker-compose.yml があるプロジェクトではコンテナ内でコマンド実行する
5. `git commit` / `git push` / PR 作成は、background agent を含めて明示的なユーザー承認後のみ実行する

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

## Model

- Agent tool で model パラメータを指定しない（親モデルを継承）
- コスト最適化のためのモデルダウングレード禁止

## Compaction

コンパクション時に以下を必ず保持すること:

- 現在のタスクの目標と進捗状況
- 変更済みファイルの一覧とその変更内容の要約
- 実行したテストコマンドとその結果
- 未解決の問題や次のステップ
- ユーザーからの重要な指示や制約

## Skill Management

- **project固有** (`<repo>/.claude/skills/`): ドメイン知識・規約・ファイルレイアウト依存、他 repo で再利用しない
- **グローバル** (`~/.claude/skills/`): 言語・ツール横断、複数 repo で再利用可能
- グローバルに作成する場合はユーザーに確認してから作成（projectのリポジトリ管理外のため）
- 重要度の高い skill / プロンプトは新規作成・大幅改訂後に `empirical-prompt-tuning` で反復改善する（収束基準: 連続 2 イテレーションで新規不明瞭点ゼロ）
