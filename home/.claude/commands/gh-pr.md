---
description: Push済みの変更からPRを作成する
---

Push済みのブランチからPull Requestを作成する。
会話コンテキストとgit情報を組み合わせて、充実したPR説明文を生成する。

## Arguments

- `$ARGUMENTS`: オプション引数
  - `--base <branch>`: マージ先ブランチ（省略時: デフォルトブランチ）
  - `--draft`: ドラフトPRとして作成

## Workflow

┌─────────────────────────────────────────────────────────┐
│  1. Gather Information                                  │
│     ├→ ブランチ情報取得（現在 + マージ先）              │
│     ├→ git diff / git log で差分・履歴を取得           │
│     └→ 会話コンテキストから情報を抽出                   │
├─────────────────────────────────────────────────────────┤
│  2. Generate PR Description                             │
│     └→ 情報を統合してPR説明文を生成                     │
├─────────────────────────────────────────────────────────┤
│  3. Create PR                                           │
│     └→ gh pr create でPR作成・URL表示                   │
└─────────────────────────────────────────────────────────┘

## Step Details

### 1. Gather Information

#### Git情報の取得

```bash
# 現在のブランチ
git branch --show-current

# マージ先ブランチ（デフォルトブランチ）
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
# または
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'

# コミット履歴
git log ${BASE_BRANCH}..HEAD --oneline

# 差分の統計
git diff ${BASE_BRANCH}...HEAD --stat

# 差分の詳細（必要に応じて）
git diff ${BASE_BRANCH}...HEAD
```

#### 会話コンテキストから抽出する情報

以下の項目を会話履歴から抽出する（該当する情報がある場合のみ）:

- **実装の背景・目的**: なぜこの変更をしたか
- **動作確認の結果**: テストしたこと、確認したこと
- **設計上の判断**: 代替案があれば、なぜこの方法を選んだか
- **既知の制限事項・注意点**: 現時点での制限や将来の課題

### 2. Generate PR Description

`skills/pr-description/template.md` を参考に、以下の構造でPR説明文を生成:

```markdown
## Summary
<!-- 変更の概要（What）と理由（Why） -->
<!-- 会話コンテキストの「背景・目的」+ git log から生成 -->

## Changes
<!-- 主な変更点をリスト形式で -->
<!-- git diff --stat から生成 -->

## Background
<!-- 会話コンテキストから抽出した背景情報 -->
<!-- 設計上の判断、代替案の検討などがあれば記載 -->

## How to Test
<!-- 動作確認方法 -->
<!-- 会話コンテキストの「動作確認の結果」から生成 -->

## Notes
<!-- 既知の制限事項、注意点など -->
<!-- 該当がなければ省略 -->

## Related Issues
<!-- 会話で言及されたIssue番号があれば -->
```

### 3. Create PR

```bash
# 通常PR
gh pr create --base ${BASE_BRANCH} --title "${TITLE}" --body "$(cat <<'EOF'
${PR_BODY}
EOF
)"

# ドラフトPR（--draft 指定時）
gh pr create --draft --base ${BASE_BRANCH} --title "${TITLE}" --body "$(cat <<'EOF'
${PR_BODY}
EOF
)"
```

## Output Format

```
## PR作成完了

**URL**: https://github.com/owner/repo/pull/123
**Title**: PRタイトル
**Base**: main ← feature-branch
**Status**: Open / Draft
```

## Notes

- このコマンドはpush済みの状態で実行することを想定
- 未push/未コミットの変更がある場合は警告を表示
- PR説明文は HEREDOC 形式で渡してフォーマットを維持
- 会話コンテキストに該当情報がない場合、そのセクションは省略可
