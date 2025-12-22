---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Style
- `type` vs `interface`: 基本は `type`、拡張が必要な場合のみ `interface`
- Non-null assertion (`!`) は禁止、適切な型ガードを使用
- `any` は禁止、`unknown` + 型ガードを使用

## Import Order
1. Node.js built-ins (`node:`)
2. External packages
3. Internal aliases (`@/`, `~/`)
4. Relative imports

## Async/Await
- Promise chain (`.then`) より async/await を優先
- 並列実行可能な場合は `Promise.all()` を使用
- エラーは適切にキャッチし、型付きエラーハンドリング

## Naming
- Variables/Functions: camelCase
- Types/Interfaces: PascalCase
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case.ts
