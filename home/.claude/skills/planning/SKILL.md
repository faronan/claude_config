---
name: planning
context: fork
description: |
  Create step-by-step implementation plans for features, refactoring, or architectural changes.
  Use when the user asks to plan, design, break down a task, or figure out how to implement something.
  Trigger words: "計画", "plan", "設計", "どう実装する", "進め方", "どうすればいい",
  "実装方法", "アプローチ", "手順", "ステップ", "how to implement", "breakdown".
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__sequential-thinking__*
---

# Planning Skill

## When to Plan
- 複数ファイルにまたがる変更
- 新機能の実装
- リファクタリング
- 不明点が多いタスク

## Plan Structure

### 1. Goal Definition
- 何を達成するか
- 成功の基準

### 2. Current State Analysis
- 関連ファイルの把握
- 既存の実装パターン
- 制約・依存関係

### 3. Approach Options
- Option A: [アプローチ1] - Pros/Cons
- Option B: [アプローチ2] - Pros/Cons
- Recommendation: [推奨案と理由]

### 4. Implementation Steps
```
[ ] Step 1: [具体的なタスク]
    - 対象ファイル: xxx
    - 変更内容: xxx
[ ] Step 2: ...
```

### 5. Risks & Mitigations
- リスク1 → 対策
- リスク2 → 対策

### 6. Verification
- [ ] テスト項目
- [ ] 動作確認項目

## Output Format
Markdown形式で、チェックボックス付きのステップリストを含める。
ユーザーが承認してから実装を開始。
