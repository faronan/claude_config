---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## 型の方針

- `type` を基本とし、declaration merging が必要な場合のみ `interface`
- `any` 禁止 → `unknown` + 型ガード
- Non-null assertion (`!`) 禁止 → 適切な型ガード or optional chaining

## Import 順序

1. Node.js built-ins (`node:`)
2. External packages
3. Internal aliases (`@/`, `~/`)
4. Relative imports
