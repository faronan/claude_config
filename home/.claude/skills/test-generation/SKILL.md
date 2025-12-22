---
name: test-generation
description: |
  Generate comprehensive tests for code.
  Auto-invoke when: "テスト", "test", "テストを書いて", adding new functions/components.
---

# Test Generation Skill

## Workflow
1. 対象コードの分析（関数シグネチャ、依存関係）
2. テストケースの洗い出し
3. テストコード生成
4. 実行して確認

## Test Case Categories
1. **Happy Path**: 正常系（期待通りの入力）
2. **Edge Cases**: 境界値、空配列、null/undefined
3. **Error Cases**: 異常系、例外発生
4. **Integration**: 依存関係との結合

## Framework Detection
- `*.test.ts` + `vitest.config` → Vitest
- `*.test.ts` + `jest.config` → Jest
- `*.test.tsx` → React Testing Library
- `*_test.py` → pytest
- `test_*.py` → pytest (prefix style)

## Output Structure
```typescript
describe('[対象名]', () => {
  describe('[メソッド/機能]', () => {
    it('should [期待動作] when [条件]', () => {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

## Guidelines
- モックは必要最小限に
- テストデータは意味のある値を使用
- 各テストは独立して実行可能に
- カバレッジだけでなく、意味のあるテストを優先
