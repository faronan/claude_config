---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/components/**"
  - "**/hooks/**"
---

# React Rules

## Component Structure
1. imports
2. types/interfaces
3. component definition
4. styles (if co-located)

## Hooks
- Custom hooks は `use` prefix 必須
- useEffect の依存配列は exhaustive に
- useMemo/useCallback は計測してから導入

## State Management
- Local state: useState/useReducer
- Server state: TanStack Query / SWR
- Global state: 最小限に（Context or Zustand）

## Patterns
- Compound Components for complex UI
- Render Props より Custom Hooks を優先
- Props drilling は 2階層まで、それ以上は Context
