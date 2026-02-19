---
name: commit-message
argument-hint: "[files to commit]"
user-invocable: false
description: |
  Generate git commit messages following Conventional Commits format in Japanese.
  Internal skill used by quick-commit and smart-commit.
  For direct commit operations, use /quick-commit (small changes) or /smart-commit (multiple logical commits).
allowed-tools:
  - Bash(git status)
  - Bash(git diff *)
  - Bash(git add *)
  - Bash(git commit *)
---

# Commit Message Skill

## Workflow
1. `git diff --staged` で変更内容を確認（未ステージなら `git status` を案内）
2. 変更内容を分析し、適切な type と scope を決定
3. メッセージを生成して表示
4. `git commit` を実行（Bashコマンド確認で承認）

## Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

## Rules
- subject: 50文字以内、現在形、末尾ピリオドなし
- body: 「なぜ」を説明、72文字折り返し
- 日本語メッセージでも type は英語

## Quick Reference
| Type | 用途 |
|------|------|
| feat | 新機能 |
| fix | バグ修正 |
| docs | ドキュメント |
| refactor | リファクタリング |
| test | テスト |
| chore | 雑務 |

**詳細な Type 一覧と例**: `type-reference.md` を参照
