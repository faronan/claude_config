---
name: workflow-implement
argument-hint: "[task description]"
description: |
  Execute implementation workflow with planning, coding, testing, and review loop.
  Trigger words: "実装して", "機能追加", "implement", "開発して", "作って", "ビルドして".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - Bash(pytest:*)
  - Skill
  - mcp__sequential-thinking__*
---

# Implementation Workflow

指定されたタスクに対して、計画→実装→テスト→レビューのループを実行する。
レビューで問題が見つかった場合は修正して再度検証する。

## Codex Runtime

Follow `../CODEX_COMPATIBILITY.md`. In Codex, perform the workflow locally by
default. Use `spawn_agent` only when the user explicitly asks for sub-agents,
delegation, or parallel agent work. `AskUserQuestion` means Plan mode
`request_user_input` or a concise conversational confirmation.

## Arguments

- `$ARGUMENTS`: 実装するタスクの説明

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Planning                                             │
│     └→ 実装計画を作成、必要ならユーザー確認              │
├─────────────────────────────────────────────────────────┤
│  2. Implementation                                      │
│     └→ 計画に基づいてコードを実装                       │
├─────────────────────────────────────────────────────────┤
│  3. Test Generation (/test-generation)                  │
│     └→ 必要なテストを作成                               │
├─────────────────────────────────────────────────────────┤
│  4. Verification                                       │
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

実装計画を作成:

- Goal Definition（何を達成するか）
- Current State Analysis（関連ファイル、既存パターン）
- Implementation Steps（具体的な手順）

**必要な場合のみユーザー承認を取得:**

- 選択肢: 「実装へ進む」「計画を修正」「キャンセル」

### 2. Implementation Phase

計画に基づいて実装:

- 計画に基づいてコードを実装
- 計画外の変更は提案のみ（実行しない）
- 破壊的変更は確認を求める

### 3. Test Generation Phase

`/test-generation` スキルを呼び出してテストを作成:

- Happy Path、Edge Cases、Error Cases をカバー
- 既存テストのパターンに合わせる

### 4. Verification Phase

検証を実行:

- テストスイートを実行
- 失敗があれば原因を分析
- 結果サマリーを報告

### 5. Review Phase

`/code-review` スキルを呼び出してレビュー:

- Correctness、Security、Performance、Maintainability をチェック
- 問題を優先度順に報告（Critical → Warning → Suggestion）

### 6. Loop Decision

- **Critical/Warning がある場合**: 修正 → 再度 Verification → Review
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

## Optional Codex Sub-Agent Roles

- Codex では通常ローカル実行。ユーザーが明示的に委譲を求めた場合のみ対応する sub-agent を使う。

## Error Handling

- **計画と実装の乖離**: Sequential Thinking MCP で計画を再分析し、乖離箇所を特定。必要に応じて再計画フェーズに戻る
- **テスト失敗が解消しない**: 失敗原因を分析。根本原因が設計レベルの場合は計画見直しをユーザーに提案
- **ループ上限（3回）到達**: ユーザーに以下の選択肢を提示:
  1. 残タスクのスコープを縮小して再試行
  2. 別の実装アプローチに切り替え
  3. 完了分をコミットして残りを別タスクに分割
  4. 変更を破棄して中止
