---
name: planning
argument-hint: "[task to plan]"
context: fork
description: |
  Create step-by-step implementation plans using Sequential Thinking MCP.
  Use when detailed step-by-step planning with analysis is needed.
  NOTE: Different from Claude Code's built-in /plan command (mode switch).
  This skill creates structured plans with goal/analysis/options/steps.
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

AskUserQuestion でユーザー承認を取得:
- 選択肢: 「承認して実装へ」「計画を修正」「キャンセル」

## Error Handling

- **要件が不明確**: AskUserQuestion で要件を明確化してから計画作成
- **対象コードが見つからない**: Glob/Grep で関連ファイルを探索
- **計画が複雑すぎる**: フェーズ分割を提案し、段階的に計画
