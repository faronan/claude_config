---
name: workflow-refactoring
argument-hint: "[refactoring target]"
description: |
  Execute refactoring workflow with analysis, safe changes, and verification loop.
  Trigger words: "大規模リファクタ", "構造改善ワークフロー", "refactoring workflow", "アーキテクチャ改善".
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - Bash(pytest:*)
  - Task
  - Skill
  - AskUserQuestion
---

# Refactoring Workflow

指定された対象に対して、分析→リファクタリング→検証のループを実行する。
振る舞いを変えずにコード品質を改善する。

## Arguments

- `$ARGUMENTS`: リファクタリング対象（ファイル、関数、モジュールなど）

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Analysis (/refactoring)                             │
│     └→ Code Smells を特定、リファクタリング計画を作成   │
├─────────────────────────────────────────────────────────┤
│  2. Execution (/refactoring)                            │
│     └→ 計画に基づいて段階的にリファクタリング           │
├─────────────────────────────────────────────────────────┤
│  3. Verification (verify-app agent)                     │
│     └→ テストを実行、振る舞いが変わっていないことを確認 │
├─────────────────────────────────────────────────────────┤
│  4. Review (/code-review)                               │
│     └→ リファクタリング結果をレビュー                   │
├─────────────────────────────────────────────────────────┤
│  5. Loop Decision                                       │
│     ├→ 追加改善あり: Step 2 に戻る                      │
│     └→ 完了                                             │
└─────────────────────────────────────────────────────────┘
```

## Step Details

### 1. Analysis Phase

`/refactoring` スキルを呼び出して分析:

- Code Smells の特定（Long Method, Duplicate Code 等）
- リファクタリング計画の作成
- 影響範囲とリスクの評価

**AskUserQuestion でユーザー承認を取得:**

- 選択肢: 「実行へ進む」「計画を修正」「キャンセル」

### 2. Execution Phase

`/refactoring` スキルの指示に従って実行:

- 一度に1つのリファクタリングのみ実行
- 各ステップ後に動作確認
- 振る舞いを変えない（機能追加しない）

### 3. Verification Phase

verify-app agent を使用:

- 全テストスイートを実行
- 振る舞いが変わっていないことを確認
- 失敗があれば即座に報告

### 4. Review Phase

`/code-review` スキルを呼び出してレビュー:

- リファクタリング結果の品質確認
- 新たな Code Smells がないか確認
- 追加改善の提案

### 5. Loop Decision

- **追加改善が必要**: Step 2 へ（ユーザー承認後）
- **品質基準を満たす**: 完了

## Safety Rules

1. **テストが通る状態を維持** - 各ステップ後にテスト
2. **一度に1つの変更** - 複数のリファクタリングを同時にしない
3. **振る舞いを変えない** - 機能追加・変更は別タスクで

## Output Format

```markdown
## リファクタリング完了: [対象]

### 実施した改善

1. [Technique]: [対象] → [結果]
2. ...

### 品質指標

- Before: [行数、複雑度など]
- After: [行数、複雑度など]

### 検証結果

- テスト: ✅ 全パス
- 振る舞い: ✅ 変更なし
```

## Notes

- 振る舞いを変える変更は `/workflow-implement` を使用
- テストがない場合は先にテスト追加を提案
- 大規模リファクタリングは段階的に実施

## Completion Criteria

以下をすべて満たした時点で完了:

- [ ] 計画したリファクタリングが完了
- [ ] 全テストがパス
- [ ] Critical/Warning 指摘なし
- [ ] 品質指標が改善（行数、複雑度など）

## Agent References

- **code-implementer**: リファクタリング実行
- **app-verifier**: テスト実行、検証

## Error Handling

- **テストが存在しない対象**: リファクタリング前にテスト追加を提案し、承認を得てから実施
- **リファクタリング後にテスト失敗**: 直前の変更を取り消し、より小さな単位で再実施
- **振る舞いの変更が必要と判明**: `/workflow-implement` への切り替えを提案
