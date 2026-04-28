---
name: switch-branch
effort: low
description: |
  Create branch with Conventional Branch naming from current changes.
  Trigger words: "ブランチ作成", "ブランチ切り替え", "switch branch", "新しいブランチ".
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git switch:*)
---

# Switch Branch

現在のgit差分を分析し、Conventional Branch形式でブランチ名を生成・作成する。

## Current State

- Current branch: !`git branch --show-current`
- Status: !`git status --porcelain`
- Diff summary: !`git diff --stat`

## Workflow

1. 上記の Current State を確認
2. 変更がある場合、`git diff` (未ステージ) または `git diff --staged` (ステージ済み) で内容を分析
3. 変更内容から適切な type と description を決定
4. `git switch -c <branch-name>` で作成・切り替え（Bashコマンド確認で承認）

## Naming Convention

```
<type>/<description>
```

### Type

| Type     | 用途               |
| -------- | ------------------ |
| feat     | 新機能             |
| fix      | バグ修正           |
| refactor | リファクタリング   |
| docs     | ドキュメント       |
| chore    | 雑務・設定         |
| test     | テスト追加         |
| perf     | パフォーマンス改善 |
| ci       | CI設定             |

### Description Rules

- kebab-case を使用（例: `user-auth`, `button-click-handler`）
- 簡潔で内容を表す名前（2-4語程度）
- Issue番号は含めない

### Examples

- `feat/oauth-login`
- `fix/button-click-handler`
- `refactor/auth-middleware`
- `docs/api-reference`
- `chore/update-deps`

## Notes

- 既存のブランチ名と重複しないよう確認する
- mainやdevelopにいる場合のみ実行を推奨
- 変更がない場合は、作業内容の説明を求める

## Error Handling

- **ブランチ名が既存と重複**: 別名を提案するか、ユーザーに確認
- **変更がない状態**: 作業内容の説明を求め、手動でブランチ名を決定
- **ブランチ作成失敗**: エラーメッセージを表示し、原因（不正な文字等）を案内
