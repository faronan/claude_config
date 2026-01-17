---
description: Execute implementation workflow with planning, coding, testing, and review loop.
---

指定されたタスクに対して、計画→実装→テスト→レビューのループを実行する。
レビューで問題が見つかった場合は修正して再度検証する。

## Arguments

- `$ARGUMENTS`: 実装するタスクの説明

## Workflow

┌─────────────────────────────────────────────────────────┐
│  1. Planning (planning skill)                           │
│     └→ 実装計画を作成、AskUserQuestionで承認            │
├─────────────────────────────────────────────────────────┤
│  2. Implementation (implementer agent)                  │
│     └→ 計画に基づいてコードを実装                       │
├─────────────────────────────────────────────────────────┤
│  3. Test Generation (test-generation skill)             │
│     └→ 必要なテストを作成                               │
├─────────────────────────────────────────────────────────┤
│  4. Verification (verify-app agent)                     │
│     └→ テストを実行、結果を分析                         │
├─────────────────────────────────────────────────────────┤
│  5. Code Review (code-review skill)                     │
│     └→ コードをレビュー、問題を指摘                     │
├─────────────────────────────────────────────────────────┤
│  6. Loop Decision                                       │
│     ├→ 問題あり: Step 2 に戻る                          │
│     └→ 問題なし: 完了                                   │
└─────────────────────────────────────────────────────────┘

## Step Details

### 1. Planning Phase

planning skill を使用して実装計画を作成:
- Goal Definition（何を達成するか）
- Current State Analysis（関連ファイル、既存パターン）
- Implementation Steps（具体的な手順）

**AskUserQuestion でユーザー承認を取得:**
- 選択肢: 「実装へ進む」「計画を修正」「キャンセル」

### 2. Implementation Phase

implementer agent を使用:
- 計画に基づいてコードを実装
- 計画外の変更は提案のみ（実行しない）
- 破壊的変更は確認を求める

### 3. Test Generation Phase

test-generation skill を使用:
- Happy Path、Edge Cases、Error Cases をカバー
- 既存テストのパターンに合わせる

### 4. Verification Phase

verify-app agent を使用:
- テストスイートを実行
- 失敗があれば原因を分析
- 結果サマリーを報告

### 5. Review Phase

code-review skill を使用:
- Correctness、Security、Performance、Maintainability をチェック
- 問題を優先度順に報告（Critical → Warning → Suggestion）

### 6. Loop Decision

- **Critical/Warning がある場合**: implementer agent で修正 → 再度 Verification → Review
- **Suggestion のみ or 問題なし**: 完了

## Completion Criteria

以下をすべて満たした時点で完了:
- [ ] 全テストがパス
- [ ] Critical/Warning レベルの指摘がない
- [ ] 計画した機能が実装されている

## Notes

- 各フェーズの結果をユーザーに報告
- 問題発生時は原因と対策を明示
- ループは最大3回まで（超過時はユーザーに相談）
