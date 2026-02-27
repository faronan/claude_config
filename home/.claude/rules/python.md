---
paths:
  - "**/*.py"
---

# Python Rules

## ツール

- Formatter / Linter: `ruff format` / `ruff check --fix`

## 方針

- 関数シグネチャに型ヒント必須
- データ構造は dataclasses または Pydantic を優先
