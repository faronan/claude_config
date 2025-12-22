---
name: github-pr-review
description: |
  Review GitHub PRs with accurate inline comments using gh CLI.
  Auto-invoke when: "PRレビュー", "PR review", "レビューして", reviewing pull requests.
  Use for: adding inline comments, replying to review comments, checking PR status.
allowed-tools:
  - Bash(gh:*)
  - Read
  - Grep
---

# GitHub PR Review Skill

## 概要
`gh` CLI を使用して正確な行番号でインラインコメントを付けるためのスキル。
LLMの推測に頼らず、明示的なコマンドで精度を確保する。

## Workflow

### 1. PR情報の取得
```bash
# PR の基本情報
gh pr view <PR番号> --json number,title,body,author,state,baseRefName,headRefName

# PR の差分（行番号付き）
gh pr diff <PR番号>
```

### 2. 既存コメントの取得
```bash
# 一般コメント
gh pr view <PR番号> --json comments

# レビューコメント（インラインコメント含む）
gh api repos/{owner}/{repo}/pulls/<PR番号>/comments
```

### 3. インラインコメントの追加
```bash
gh api repos/{owner}/{repo}/pulls/<PR番号>/comments \
  -f body="コメント内容" \
  -f commit_id="$(gh pr view <PR番号> --json headRefOid -q .headRefOid)" \
  -f path="ファイルパス" \
  -f side="RIGHT" \
  -F line=<行番号>
```

### 4. コメントへの返信
```bash
gh api repos/{owner}/{repo}/pulls/<PR番号>/comments \
  -f body="返信内容" \
  -F in_reply_to=<元コメントID>
```

## 行番号の特定方法

`gh pr diff` の出力から行番号を特定する際の注意：

- `+` で始まる行 → 追加された行（HEAD側、`side: RIGHT`）
- `-` で始まる行 → 削除された行（BASE側、`side: LEFT`）
- 空白で始まる行 → 変更なし

**重要**: `@@ -開始,行数 +開始,行数 @@` のハンク情報から実際の行番号を計算する。

## Output Format
```
## PR #<番号>: <タイトル>

### 変更概要
- <ファイル1>: <変更内容>
- <ファイル2>: <変更内容>

### レビュー結果
✅ LGTM / ⚠️ 要修正 / ❌ 要再設計

### コメント
[ファイル:行番号] 指摘内容
→ 提案（必要に応じて）
```

## Constraints
- インラインコメントは**必ず `gh api` コマンドで追加**（推測で行番号を指定しない）
- コメント追加前に `gh pr diff` で行番号を確認
- 破壊的な操作（PR close, merge）は実行前に確認を求める
