---
name: gh-issue
argument-hint: "[issue number]"
description: Analyze and fix GitHub issue
disable-model-invocation: true
allowed-tools:
  - Bash(gh issue:*)
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - AskUserQuestion
---

# GitHub Issue Fix

GitHub Issue を分析して修正する。

## Workflow

1. `gh issue view $ARGUMENTS` で詳細を取得
2. 問題を理解し、関連ファイルを特定
3. 修正計画を提示（planning スキル参照）
4. AskUserQuestion で承認を取得後、実装
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
- 複雑な Issue は wf-implement または wf-fix-bug へ誘導
