---
name: workflow-implement
argument-hint: "[task description]"
description: |
  Execute implementation workflow with planning, coding, testing, and review loop.
  Trigger words: "実装して", "機能追加", "implement", "開発して", "作って", "ビルドして".
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - Bash(pytest:*)
  - Task
  - Skill
  - AskUserQuestion
  - mcp__sequential-thinking__*
---

# Implementation Workflow

指定されたタスクに対して、計画→実装→テスト→レビューのループを実行する。
レビューで問題が見つかった場合は修正して再度検証する。

## Arguments

- `$ARGUMENTS`: 実装するタスクの説明

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Planning (task-planner agent)                            │
│     └→ 実装計画を作成、AskUserQuestionで承認            │
├─────────────────────────────────────────────────────────┤
│  2. Implementation (code-implementer agent)                  │
│     └→ 計画に基づいてコードを実装                       │
├─────────────────────────────────────────────────────────┤
│  3. Test Generation (/test-generation)                  │
│     └→ 必要なテストを作成                               │
├─────────────────────────────────────────────────────────┤
│  4. Verification (verify-app agent)                     │
│     └→ テストを実行、結果を分析                         │
├─────────────────────────────────────────────────────────┤
│  5. Code Review (/code-review)                          │
│     └→ コードをレビュー、問題を指摘                     │
├─────────────────────────────────────────────────────────┤
│  6. Loop Decision                                       │
│     ├→ 問題あり: Step 2 に戻る                          │
│     └→ 問題なし: 完了                                   │
└─────────────────────────────────────────────────────────┘
```

## Step Details

### 1. Planning Phase

task-planner agent を使用して実装計画を作成:

- Goal Definition（何を達成するか）
- Current State Analysis（関連ファイル、既存パターン）
- Implementation Steps（具体的な手順）

**AskUserQuestion でユーザー承認を取得:**

- 選択肢: 「実装へ進む」「計画を修正」「キャンセル」

### 2. Implementation Phase

code-implementer agent を使用:

- 計画に基づいてコードを実装
- 計画外の変更は提案のみ（実行しない）
- 破壊的変更は確認を求める

### 3. Test Generation Phase

`/test-generation` スキルを呼び出してテストを作成:

- Happy Path、Edge Cases、Error Cases をカバー
- 既存テストのパターンに合わせる

### 4. Verification Phase

verify-app agent を使用:

- テストスイートを実行
- 失敗があれば原因を分析
- 結果サマリーを報告

### 5. Review Phase

`/code-review` スキルを呼び出してレビュー:

- Correctness、Security、Performance、Maintainability をチェック
- 問題を優先度順に報告（Critical → Warning → Suggestion）

### 6. Loop Decision

- **Critical/Warning がある場合**: code-implementer agent で修正 → 再度 Verification → Review
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

## Agent References

- **task-planner**: 実装計画の作成
- **code-implementer**: コード実装
- **app-verifier**: テスト実行、検証

## Error Handling

- **計画と実装の乖離**: Sequential Thinking MCP で計画を再分析し、乖離箇所を特定。必要に応じて再計画フェーズに戻る
- **テスト失敗が解消しない**: error-investigator エージェントで失敗原因を分析。根本原因が設計レベルの場合は `git stash` で変更を退避し、計画見直しをユーザーに提案
- **ループ上限（3回）到達**: ユーザーに AskUserQuestion で以下の選択肢を提示:
  1. 残タスクのスコープを縮小して再試行
  2. 別の実装アプローチに切り替え
  3. 完了分をコミットして残りを別タスクに分割
  4. 変更を破棄して中止
