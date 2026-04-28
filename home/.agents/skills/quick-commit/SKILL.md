---
name: quick-commit
effort: low
description: |
  Quick commit with explicit confirmation in Codex (for small changes).
  Trigger words: "即コミット", "すぐコミット", "quick commit", "サクッとコミット".
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git add:*)
  - Bash(git commit:*)
---

# Quick Commit

ステージされた小さな変更のコミットメッセージを素早く作成し、ユーザー確認後にコミットする。
小さな変更（typo修正、フォーマット等）用。

## Codex Runtime

Follow `../CODEX_COMPATIBILITY.md`. In Codex, never run `git commit` without
explicit user confirmation, even for quick commits.

<!-- codex-requires-confirmation: git-commit -->

## Current Changes

- Staged files: !`git diff --staged --name-only`
- Staged diff: !`git diff --staged --stat`

## Workflow

1. 上記の Current Changes を確認
2. 変更が3ファイル以下かつ50行以下なら続行、それ以上なら `/smart-commit` の使用を案内して **終了**
3. commit-message スキルのルールに従ってメッセージ生成
4. 生成したメッセージを提示し、ユーザー確認後に `git commit` 実行

## Commit Message Format

```
<type>(<scope>): <subject>
```

- **subject**: 50文字以内、日本語、現在形
- **type/scope**: 英語

詳細はこの skill ディレクトリの `type-reference.md` を参照

## Error Handling

- **ステージされた変更がない**: `git status` で状況を表示し、ステージングを案内
- **閾値超過（3ファイル超 or 50行超）**: `/smart-commit` の使用を案内して終了
- **コミット失敗**: エラーメッセージを表示し、原因（pre-commit hook 等）を案内
