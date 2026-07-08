---
name: commit-message
effort: low
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

## Commit Skill Selection Flow

```
コミットしたい
    ├── 小さな変更（3ファイル以下 & 50行以下）
    │   └── /quick-commit → 明示承認後にコミット
    ├── 複数の論理的変更が混在
    │   └── /smart-commit → グループ分割して複数コミット
    └── 通常の変更（単一の論理変更）
        └── Claude が本スキルを内部的に使用（ユーザー操作不要）
```

## Workflow

1. `git diff --staged` で変更内容を確認（未ステージなら `git status` を案内）
2. 変更内容を分析し、適切な type と scope を決定
3. メッセージを生成して表示
4. ユーザーの明示承認を得た場合のみ `git commit` を実行

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

| Type     | 用途             |
| -------- | ---------------- |
| feat     | 新機能           |
| fix      | バグ修正         |
| docs     | ドキュメント     |
| refactor | リファクタリング |
| test     | テスト           |
| chore    | 雑務             |

**詳細な Type 一覧と例**: `${CLAUDE_SKILL_DIR}/type-reference.md` を参照

## Error Handling

- **ステージされた変更がない**: `git status` を表示し、ステージング方法を案内
- **変更が大きすぎる**: `/smart-commit` での分割コミットを提案
- **git リポジトリ外**: エラーを報告し、リポジトリ内での実行を案内
