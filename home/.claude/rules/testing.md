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

## テストデータ

- Factory パターンで生成（テスト間の依存を避ける）

## 制限

- Snapshot test は最小限に（変更に脆い）
- 新規コードはカバレッジ 80% 以上を目標
- エッジケース・エラーケースを優先的にカバー
