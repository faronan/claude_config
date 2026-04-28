---
name: gh-issue-fix
argument-hint: "[issue number]"
description: |
  Analyze and fix GitHub issue.
  Trigger words: "Issue修正", "Issueを直して", "fix issue", "Issue対応", "#".
allowed-tools:
  - Bash(gh issue:*)
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - Skill
---

# GitHub Issue Fix

GitHub Issue を分析して修正する。

## Codex Runtime

Follow `../CODEX_COMPATIBILITY.md`. In Codex, use `gh` through `shell_command`
and request approval for network or auth-sensitive commands when required.
`AskUserQuestion` means an explicit confirmation in the current conversation.

<!-- codex-requires-confirmation: issue-implementation -->

## Workflow

1. `gh issue view $ARGUMENTS` で詳細を取得
2. 問題を理解し、関連ファイルを特定
3. 修正計画を提示（planning スキル参照）
4. ユーザー承認を取得後、実装
   - 選択肢: 「実装開始」「計画を修正」「キャンセル」
5. テスト実行
6. コミット（commit-message スキル使用）

## Plan Structure

```markdown
## Issue #[番号]: [タイトル]

### 問題の理解

[Issueの内容を要約]

### 原因分析

[推定される原因]

### 修正計画

1. [ ] [修正ステップ1]
2. [ ] [修正ステップ2]

### 影響範囲

- [変更するファイル]

### 検証方法

- [テスト方法]
```

## Notes

- Issue番号は `$ARGUMENTS` から取得
- Issue が見つからない場合はエラーを報告
- 複雑な Issue は workflow-implement または workflow-fix-bug へ誘導

## Error Handling

- **Issue が見つからない**: Issue 番号を再確認し、リポジトリが正しいか確認
- **Issue がクローズ済み**: 状態をユーザーに伝え、それでも対応するか確認
- **修正後テスト失敗**: 変更を巻き戻し、原因を分析してから再修正
- **複雑すぎる Issue**: workflow-implement または workflow-fix-bug への誘導を案内
