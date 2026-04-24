---
paths:
  - "**/*"
---

# Git Rules

Skills（commit-message, gh-pr-create）が操作を支援する。
本ルールはそれらが扱わない制約・方針を定義する。

## ブランチ

- main への直接コミット禁止（feature branch → PR 必須）
- 命名: `<type>/<説明>` （例: `feat/add-auth`, `fix/login-error`）

## コミット

- 1コミット = 1論理変更（atomic commits）

## マージ戦略

- feature → main: squash merge
- hotfix → main: 通常 merge

## Scope

- モノレポ: パッケージ名（例: `feat(api): ...`）
- 単一パッケージ: ディレクトリ名（例: `fix(auth): ...`）
- 省略可（小さな変更）
