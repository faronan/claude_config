---
name: workflow-tdd
argument-hint: "[feature description]"
description: |
  Execute TDD workflow with RED → GREEN → REFACTOR cycle.
  Trigger words: "TDD", "テスト駆動", "テストファースト", "RED GREEN REFACTOR", "TDDで実装".
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
---

# TDD Workflow

指定された機能に対して、テスト駆動開発（TDD）のサイクルを実行する。
テストファーストのアプローチで品質の高いコードを実装する。

## Arguments

- `$ARGUMENTS`: 実装する機能の説明

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  TDD Cycle: RED → GREEN → REFACTOR                      │
│                                                          │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐        │
│  │   RED    │ ──→ │  GREEN   │ ──→ │ REFACTOR │ ──┐    │
│  │ 失敗する │     │ パスする │     │  改善    │   │    │
│  │ テスト   │     │ 最小実装 │     │  リファ  │   │    │
│  └──────────┘     └──────────┘     └──────────┘   │    │
│       ↑                                           │    │
│       └───────────────────────────────────────────┘    │
│                     次の機能へ                          │
└─────────────────────────────────────────────────────────┘
```

## Step Details

### 0. Planning Phase

機能を小さなテスト可能な単位に分解:

1. 機能の要件を明確化
2. テストケースをリストアップ
3. 実装順序を決定（単純→複雑）

**AskUserQuestion でユーザー承認を取得:**

- 選択肢: 「TDDサイクル開始」「計画を修正」「キャンセル」

### 1. RED Phase（失敗するテストを書く）

`/test-generation` スキルを呼び出してテストパターンを確認し、テストを作成:

- **1つのテストのみ** を書く
- 期待する振る舞いを明確に定義
- テストを実行し、**失敗することを確認**

```bash
# テスト実行例
pnpm test -- --watch=false --testPathPattern="target-test"
```

**確認ポイント:**

- [ ] テストが失敗している（RED状態）
- [ ] 失敗理由が明確（実装がないから失敗）

### 2. GREEN Phase（テストを通す最小実装）

Task tool で `code-implementer` agent を起動して実装:

- テストを通す**最小限のコード**を書く
- 完璧なコードを書こうとしない
- ハードコード値でも可（後でREFACTOR）

```bash
# テスト実行
pnpm test
```

**確認ポイント:**

- [ ] テストがパスしている（GREEN状態）
- [ ] 余計なコードを追加していない

### 3. REFACTOR Phase（コードを改善）

`/code-review` スキルを呼び出してコード品質を確認し、リファクタリング:

- 重複の除去（DRY）
- 命名の改善
- 構造の整理
- **テストが通る状態を維持**

```bash
# リファクタリング後にテスト
pnpm test
```

**確認ポイント:**

- [ ] テストがパスしている
- [ ] コードが読みやすくなった
- [ ] 重複が除去された

### 4. 次のサイクルへ

計画したテストケースがすべて完了するまでサイクルを繰り返す:

1. → RED（次のテストを書く）
2. → GREEN（実装）
3. → REFACTOR（改善）

## Coverage Goal

**目標: 80%以上のカバレッジ**

```bash
# カバレッジ確認コマンド例
pnpm test -- --coverage

# Python の場合
pytest --cov=src --cov-report=term-missing
```

## Completion Criteria

以下をすべて満たした時点で完了:

- [ ] 計画した全テストケースが実装済み
- [ ] 全テストがパス（GREEN）
- [ ] カバレッジ 80% 以上
- [ ] REFACTOR 完了（重複なし、読みやすい）

## Best Practices

### DO

- 1回のサイクルで1つのテストのみ
- テストファーストを厳守
- 小さなステップで進む
- 各サイクル後にコミット検討

### DON'T

- 複数のテストを一度に書かない
- テスト前に実装しない
- GREEN後にREFACTORをスキップしない
- 大きな変更を一度にしない

## Notes

- 各フェーズの状態（RED/GREEN）を報告
- テスト失敗時は原因を明示
- 複雑な機能は小さなテストに分解
- 詰まった場合はユーザーに相談

## Agent References

- **code-implementer**: GREEN Phase での最小実装

## Error Handling

- **RED Phase でテストが通ってしまう**: テスト条件を見直し、未実装部分を正しく検証するテストに修正
- **GREEN Phase で最小実装が困難**: 機能をさらに小さな単位に分解し、段階的に実装
- **REFACTOR Phase でテストが壊れる**: `git diff` で変更を確認し、リファクタリングを `git checkout -- .` で取り消してから、より小さな変更単位で再試行
- **サイクル全体が行き詰まった場合**: ユーザーに AskUserQuestion で以下の選択肢を提示:
  1. 現在のサイクルを小さな単位に再分解
  2. 完了分をコミットして残りを別タスクに分割
  3. アプローチを変更して再計画
