---
name: refactoring
argument-hint: "[target to refactor]"
context: fork
description: |
  Identify code smells and safely refactor code while preserving behavior.
  Use when the user asks to refactor, clean up, improve structure, or remove duplication.
  Trigger words: "リファクタ", "refactor", "整理", "改善", "コードを綺麗に", "重複を削除",
  "きれいにして", "直して", "構造改善", "DRY", "clean up", "simplify".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - AskUserQuestion
---

# Refactoring Skill

## Workflow
1. 現状分析（Code Smells の特定）
2. リファクタリング計画の提示
3. AskUserQuestion でユーザー承認を取得
   - 選択肢: 「実行」「計画を修正」「キャンセル」
4. 段階的に実行（各ステップでテスト）

## Common Code Smells
- **Long Method**: 関数が長すぎる（目安: 20行以上）
- **Large Class**: クラスの責務が多すぎる
- **Duplicate Code**: 重複コード
- **Long Parameter List**: 引数が多すぎる（目安: 4つ以上）

## Safety Rules
1. **テストが通る状態を維持**
2. 一度に1つのリファクタリングのみ
3. 各ステップ後にテスト実行
4. 振る舞いを変えない（機能追加しない）

## Output Format
```
## Refactoring Plan

### Identified Issues
1. [Code Smell]: [場所] - [説明]

### Proposed Changes
1. [Technique]: [対象] → [変更後]
   - 影響範囲: [ファイルリスト]
   - リスク: [低/中/高]

実行してよろしいですか？
```

**詳細なカタログと例**: `catalog.md` を参照

## Error Handling

- **テスト失敗**: リファクタリングを巻き戻し、原因を分析してからやり直す
- **影響範囲が不明**: Grep/Glob で参照箇所を網羅的に確認してから変更
- **対象ファイルが見つからない**: ユーザーに正しいパスを確認
