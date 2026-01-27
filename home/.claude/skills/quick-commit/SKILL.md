---
name: quick-commit
description: Quick commit without confirmation (for small changes)
disable-model-invocation: true
allowed-tools:
  - Bash(git diff:*)
  - Bash(git add:*)
  - Bash(git commit:*)
---

# Quick Commit

ステージされた変更を確認せずに即座にコミットする。
小さな変更（typo修正、フォーマット等）用。

## Current Changes
- Staged files: !`git diff --staged --name-only`
- Staged diff: !`git diff --staged --stat`

## Workflow

1. 上記の Current Changes を確認
2. 変更が3ファイル以下かつ50行以下なら続行、それ以上なら警告
3. commit-message スキルのルールに従ってメッセージ生成
4. 確認なしで `git commit` 実行

## Commit Message Format

```
<type>(<scope>): <subject>
```

- **subject**: 50文字以内、日本語、現在形
- **type/scope**: 英語

詳細は `skills/commit-message/type-reference.md` を参照
