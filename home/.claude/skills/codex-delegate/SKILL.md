---
name: codex-delegate
argument-hint: "[review|research|rescue] [target or task]"
context: fork
description: |
  Codex CLI に委譲してセカンドオピニオン取得・大規模調査・行き詰まり時のタスク救援を行う。
  Use when the user wants a second opinion from a different model, needs to run a large investigation
  without burning Claude context, or wants to hand off a stuck task to Codex.
  Trigger words: "Codex に聞いて", "コーデックスに聞いて", "セカンドオピニオン", "second opinion",
  "別視点でレビュー", "別モデルで", "adversarial review", "コーデックスに任せて",
  "Codex に調べさせて", "Codex で調査", "rescue", "タスク委譲".
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Codex Delegate Skill

## Purpose

Claude Code から OpenAI Codex CLI (`codex exec`) を呼び出し、以下の用途で別モデル（GPT-5.5）に作業を委譲する。

- **review**: Claude が書いたコード/設計のセカンドオピニオン取得（バイアス相殺）
- **research**: コンテキスト消費の大きい全リポ走査・複数ライブラリ比較・長文要約
- **rescue**: Claude が行き詰まったタスクの引き継ぎ実行

`codex` コマンドは事前にインストール済みであることを前提（`npm install -g @openai/codex`）。

## Modes

### review (セカンドオピニオン)

Claude のコード/設計を Codex に批判的レビューさせる。`adversarial review` も同モードで対応。

実行コマンド:

```bash
codex exec --full-auto --sandbox read-only --cd "$REPO_ROOT" \
  "次のコードを批判的にレビューしてください。確認や質問は不要です。
   具体的な指摘・修正案・コード例まで自主的に出力してください。
   観点: 1) Correctness 2) Security 3) Performance 4) Maintainability
   対象: <file path or diff>"
```

### research (大規模調査)

Claude のコンテキストを消費せずに Codex に長時間調査を委譲。owayo パターンの主用途。

実行コマンド:

```bash
codex exec --full-auto --sandbox read-only --cd "$REPO_ROOT" \
  "次の調査を行い、出典 URL 付きで構造化レポートを返してください。
   確認や質問は不要です。具体的な提案・コード例まで自主的に出力してください。
   調査内容: <task>"
```

### rescue (タスク委譲)

Claude が行き詰まった際、現在の進捗・残タスクを Codex に渡して継続実行。書き込み権限を許可する唯一のモード。

実行コマンド:

```bash
codex exec --full-auto --sandbox workspace-write --cd "$REPO_ROOT" \
  "次のタスクを引き継ぎ、実装を完了させてください。
   確認や質問は不要です。具体的な変更・コミット候補まで自主的に進めてください。
   これまでの進捗: <summary>
   残タスク: <todo>
   制約: <constraints if any>"
```

`workspace-write` は Claude 側 settings.json で `ask` に登録されており、起動時にユーザー確認が入る。

## Workflow

1. ユーザー発話から mode を判定（明示指定がなければ review をデフォルト）
2. `$REPO_ROOT` を `git rev-parse --show-toplevel` で解決
3. プロンプトテンプレート（後述）に target/task を埋め込む
4. `codex exec` を起動し、stdout を逐次表示
5. Codex の出力を「## Codex の意見」セクションで包んで報告
6. Claude 自身の最終結論と並置（review/research の場合）/ 引き継いだ作業の結果を要約（rescue の場合）

## Prompt Template Rules

- **必ず含める**: 「確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください」
  - Codex がインタラクティブモード相当の挙動で停止することを防ぐ
- **モデル指定はしない**: `--model` を省略し、`~/.codex/config.toml` のデフォルト (`gpt-5.5`) に従う（モデル選定の SoT を一箇所に）
- **sandbox 境界**: review/research は `read-only` 固定、rescue のみ `workspace-write`
- **`--cd`**: 必ずリポルートを明示（カレントディレクトリ依存を排除）

## Output Format

````
## Codex への委譲 (mode=<mode>)

**コマンド**:
```bash
<実行した codex exec コマンド>
````

## Codex の意見

<codex exec の出力をそのまま転記>

## Claude のコメント

<Codex の意見への所感、最終判断、次アクション>

```

## Constraints

- **rescue 以外は `read-only` 固定**: 誤って書き込みを起こさない
- **`codex` コマンド未検出時は明示的にエラー**: `command -v codex` で事前チェック
- **`codex exec` のタイムアウトは設定しない**: 長時間調査用途のため。ユーザーが Ctrl+C で中断可能
- **Codex の出力をそのまま信頼しない**: 「Codex の意見」として明示し、Claude の判断と分離

## Error Handling

- **`codex` 未インストール**: 「`npm install -g @openai/codex` でインストールしてください」と通知して終了
- **`git rev-parse` 失敗**: Git リポ外。`--cd $(pwd)` で代替し、ユーザーに警告
- **Codex がエラー終了**: stderr を表示し、プロンプトの問題（指示が曖昧、対象パス不在など）を診断
- **Codex の出力が空**: プロンプトテンプレートの「自主的に出力してください」が抜けていないか確認

## References

- owayo「Claude Code から Codex を呼ぶ：MCP から Skills へ」: https://zenn.dev/owayo/articles/63d325934ba0de
- OpenAI 公式 codex-plugin-cc: https://github.com/openai/codex-plugin-cc
- Codex CLI 公式ドキュメント: https://developers.openai.com/codex/config-reference
```
