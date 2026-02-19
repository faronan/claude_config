---
paths:
  - "**/*"
---

# Git Rules

Skills（commit-message, switch-branch, gh-pr-create）が操作を支援する。
本ルールはそれらが扱わない制約・方針を定義する。

## Breaking Change

- Footer に `BREAKING CHANGE: 説明` を記載
- Type に `!` を付与（例: `feat!: API変更`）

## ブランチ保護

- main への直接 push 禁止（feature branch → PR 必須）
- main への force push 禁止

## マージ戦略

- feature → main: squash merge（コミット履歴を整理）
- hotfix → main: 通常 merge

## Scope

- モノレポ: パッケージ名をスコープに使用（例: `feat(api): ...`）
- 単一パッケージ: ディレクトリ名をスコープに使用（例: `fix(auth): ...`）
- スコープは省略可能（小さな変更の場合）
