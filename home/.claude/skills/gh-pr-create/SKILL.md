---
name: gh-pr-create
argument-hint: "[options: --base, --draft]"
description: |
  Push済みの変更からPRを作成する。
  Trigger words: "PR作成", "PRを作って", "create PR", "プルリク作成", "pull request".
disable-model-invocation: true
allowed-tools:
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git symbolic-ref:*)
  - Bash(git ls-remote:*)
  - Bash(git fetch:*)
  - Bash(git status:*)
  - Bash(gh repo view:*)
  - Read
  - AskUserQuestion
# Note: gh pr create は allowed-tools に含めない（実行前に確認を求める）
---

# GitHub PR Create

Push済みのブランチからPull Requestを作成する。
会話コンテキストとgit情報を組み合わせて、充実したPR説明文を生成する。

## Arguments

- `$ARGUMENTS`: オプション引数
  - `--base <branch>`: マージ先ブランチ（省略時: デフォルトブランチ）
  - `--draft`: ドラフトPRとして作成

## Context（自動収集）

- Current branch: !`git branch --show-current`
- Default branch: !`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`
- Working tree: !`git status --porcelain`

## Workflow

### 1. Collect Remaining Context

以下のコマンドを実行して追加情報を収集する:

- `git ls-remote --heads origin <current_branch>` → リモートブランチの存在確認
- `git log origin/<current_branch>..HEAD --oneline` → Unpushed commits（リモートブランチが存在する場合のみ）
- `git log <default_branch>..HEAD --oneline` → Commits（Default branch の値を使用）
- `git diff <default_branch>...HEAD --stat` → Diff stat（Default branch の値を使用）

### 2. Validate

Context の結果を確認し、NGなら理由を伝えて **中断** する。

| チェック項目       | 期待値                     | NGの場合                                         |
| ------------------ | -------------------------- | ------------------------------------------------ |
| Working tree       | 空（変更なし）             | 「先にコミットしてください」                     |
| Remote branch 存在 | `git ls-remote` で結果あり | 「先に `git push origin <branch>` してください」 |
| Unpushed commits   | 空（全てpush済み）         | 「先に `git push` してください」                 |
| Current branch     | main/master 以外           | 「featureブランチで実行してください」            |

**禁止**: `git push` を代わりに実行してはいけない。

### 3. Gather & Generate

#### ベースブランチ

- `--base` 指定あり → その値を使用（Context の Default branch と異なる場合は diff/log を再取得）
- 指定なし → Context の Default branch を使用

#### PR テンプレートの検出

リポジトリに PR テンプレートがあれば **そのフォーマットに従う**（優先順）:

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `docs/pull_request_template.md`

テンプレートが見つからない場合は `${CLAUDE_SKILL_DIR}/template.md` を参照する。

#### 変更種別の自動判定

コミットメッセージの Conventional Commits 接頭辞から変更種別を判定し、テンプレート選択に活用する:

| 接頭辞パターン                  | テンプレート | 追加セクション          |
| ------------------------------- | ------------ | ----------------------- |
| `feat:` が主                    | 機能追加用   | Motivation, How to Test |
| `fix:` が主                     | バグ修正用   | Root Cause, Solution    |
| `refactor:` or 大量ファイル変更 | 大規模変更用 | Scope, Migration Guide  |
| その他                          | 標準         | —                       |

#### PR説明文の生成

以下のソースを統合して説明文を生成する:

- **git 情報**: Context の diff stat・commits、必要に応じて `git diff` で詳細取得
- **会話コンテキスト**: 実装の背景・目的、動作確認結果、設計判断、既知の制限事項

該当情報がないセクションは省略する。

### 4. Preview & Confirm

生成した内容を **ユーザーに提示** し、承認を得てから次へ進む:

```
## PR プレビュー

**Title**: PRタイトル
**Base**: main <- feature-branch
**Draft**: Yes / No

---

(PR説明文の全文)

---

この内容でPRを作成しますか？
```

修正要望があれば反映してから再提示する。

### 5. Create PR

ユーザー承認後、`gh pr create` を実行する。

- PR説明文は HEREDOC 形式で渡してフォーマットを維持
- 作成完了後、以下の形式で結果を表示:

```
## PR作成完了

**URL**: https://github.com/owner/repo/pull/123
**Title**: PRタイトル
**Base**: main <- feature-branch
**Status**: Open / Draft
```

## Guidelines

- タイトル: 50文字以内、変更内容を端的に
- 本文: **なぜ**この変更が必要かを重視
- テンプレート集: `${CLAUDE_SKILL_DIR}/template.md` 参照（リポジトリにテンプレートがない場合のフォールバック）

## Notes

- **重要**: このスキルはpush済みの状態で実行することを前提とする
- **禁止**: `git push` を実行してはいけない（ユーザーが自分でpushする）

## Error Handling

- **未push のコミットがある**: `git push` を案内し、スキルを中断
- **Working tree が dirty**: 先にコミットするよう案内して中断
- **main/master ブランチで実行**: feature ブランチへの切り替えを案内して中断
- **gh pr create 失敗**: エラーメッセージを表示し、原因（権限・ネットワーク等）を案内
