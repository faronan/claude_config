---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/*.spec.tsx"
  - "**/tests/**"
  - "**/__tests__/**"
  - "**/*_test.py"
  - "**/test_*.py"
---

# Testing Rules

## Naming
- `describe`: 対象（クラス名、関数名、コンポーネント名）
- `it`/`test`: "should [期待動作] when [条件]"

## Structure (AAA)
1. **Arrange**: テストデータ・モック準備
2. **Act**: テスト対象の実行
3. **Assert**: 結果検証

## Best Practices
- 1テスト1アサーション を目指す（複数でも関連性があればOK）
- 外部依存はモック化
- テストデータは Factory パターンで生成
- Snapshot test は最小限に

## Coverage
- 新規コードは最低80%カバレッジ目標
- エッジケース、エラーケースを優先
