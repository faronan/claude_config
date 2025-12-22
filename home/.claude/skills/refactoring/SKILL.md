---
name: refactoring
description: |
  Guide and execute code refactoring safely.
  Auto-invoke when: "リファクタ", "refactor", "整理", "改善", code smell detection.
---

# Refactoring Skill

## Workflow
1. 現状分析（Code Smells の特定）
2. リファクタリング計画の提示
3. ユーザー承認
4. 段階的に実行（各ステップでテスト）

## Common Code Smells
- **Long Method**: 関数が長すぎる（目安: 20行以上）
- **Large Class**: クラスの責務が多すぎる
- **Duplicate Code**: 重複コード
- **Feature Envy**: 他クラスのデータを過度に使用
- **Data Clumps**: 常にセットで使われるデータ群
- **Primitive Obsession**: プリミティブ型の過度な使用
- **Long Parameter List**: 引数が多すぎる（目安: 4つ以上）

## Refactoring Catalog
| Smell | Technique |
|-------|-----------|
| Long Method | Extract Method |
| Duplicate Code | Extract Method / Pull Up Method |
| Large Class | Extract Class |
| Feature Envy | Move Method |
| Data Clumps | Introduce Parameter Object |
| Primitive Obsession | Replace Primitive with Object |
| Long Parameter List | Introduce Parameter Object |

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

### Execution Order
[ ] Step 1: ...
[ ] Step 2: ...

実行してよろしいですか？
```
