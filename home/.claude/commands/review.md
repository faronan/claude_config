---
description: |
  Execute code review using @code-reviewer agent.
  Use BEFORE committing changes or creating PRs.
  Trigger: "レビュー", "review", "コードチェック"
---

@code-reviewer サブエージェントを使用してコードレビューを実行。

対象: $ARGUMENTS（指定がなければ `git diff --staged` または `git diff HEAD~1`）
