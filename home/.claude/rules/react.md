---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---

# React Rules

## State Management

- Local: useState / useReducer
- Server state: TanStack Query / SWR
- Global: 最小限に（Context or Zustand）

## パフォーマンス

- useMemo / useCallback は計測で効果を確認してから導入
- Props drilling は 2 階層まで、それ以上は Context

## パターン

- Custom Hooks > Render Props
- Compound Components for complex UI
