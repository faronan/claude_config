---
description: コードレビューを実行
allowed-tools:
  - Read
  - Grep
  - Glob
---

@code-reviewer サブエージェントを使用してコードレビューを実行。

対象: $ARGUMENTS（指定がなければ `git diff --staged` または `git diff HEAD~1`）

出力形式:
- 🔴 Critical: 即座に修正必須
- 🟡 Warning: 修正推奨
- 🟢 Info: 改善提案
- ✅ Good: 良い実装のハイライト
