---
name: planning
description: |
  Create implementation plans for complex tasks.
  Auto-invoke when: "計画", "plan", "設計", complex feature requests, architectural decisions.
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
