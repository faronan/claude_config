---
name: smart-commit
description: |
  Split changes into logical commits with Conventional Commits format.
  Trigger words: "分割コミット", "スマートコミット", "コミット分けて", "smart commit", "論理コミット".
disable-model-invocation: true
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git add:*)
  - Bash(git log:*)
  - AskUserQuestion
---

# Smart Commit

git diffの変更を論理的なグループに分割し、適切な粒度で複数の独立したコミットを作成する。

## Current State

- Status: !`git status --porcelain`
- Diff stat: !`git diff --stat`

## Workflow

1. 上記の Current State を確認
2. `git diff` で詳細な差分を取得
3. 変更を論理的なグループに分類
4. 分類結果をユーザーに提示（グループ一覧とコミット順序）
5. AskUserQuestion で分類確認後、各グループごとに:
   - `git add <files>` でステージング
   - Conventional Commits形式でメッセージ生成
   - `git commit` 実行
6. 全コミット完了後、`git log --oneline -n <count>` で結果表示

## Grouping Strategy

### 優先順位

1. **機能単位**: 同じ機能に関する複数ファイルの変更をまとめる
2. **目的単位**: feat/fix/refactor などタイプが同じ変更をまとめる
3. **依存関係**: 設定ファイル → 実装コードの順序で整理

### 分類の例

```
グループ1: feat(auth) - OAuth認証の追加
  - src/auth/oauth.ts (新規)
  - src/auth/index.ts (変更)
  - tests/auth/oauth.test.ts (新規)

グループ2: fix(ui) - ボタンのスタイル修正
  - src/components/Button.tsx (変更)
  - src/styles/button.css (変更)

グループ3: chore(deps) - 依存関係の更新
  - package.json (変更)
  - pnpm-lock.yaml (変更)
```

## Commit Message Format

```
<type>(<scope>): <subject>

<body>
```

- **subject**: 50文字以内、日本語、現在形
- **body**: 「なぜ」を説明、72文字折り返し
- **type/scope**: 英語

詳細は `skills/commit-message/type-reference.md` を参照

## User Confirmation

AskUserQuestion ツールを使用してインラインで確認（対話を終了せず継続）:

1. **分類確認**: グループ一覧を表示後、AskUserQuestion で確認
   - 選択肢: 「このまま実行」「グループを統合」「グループを分割」「キャンセル」
   - 「Other」で詳細な修正指示も可能

2. **コミット確認**: 各コミットメッセージ表示後、AskUserQuestion で確認
   - 選択肢: 「コミット実行」「メッセージ修正」「スキップ」

## Notes

- 単一の変更しかない場合は通常のコミットを推奨
- ステージ済みの変更がある場合は警告を表示
- 途中でキャンセル可能（コミット済みのものは残る）

## Error Handling

- **変更がない**: `git status` の結果を表示し、変更がないことを通知
- **単一の変更のみ**: `/quick-commit` の使用を案内
- **ステージ済みの変更あり**: 警告を表示し、既存のステージングをどうするか確認
- **コミット途中で失敗**: 完了済みコミットの一覧を表示し、残りの対応を案内
