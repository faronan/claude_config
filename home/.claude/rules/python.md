---
paths:
  - "**/*.py"
---

# Python Rules

## Style
- Formatter: ruff format
- Linter: ruff check --fix
- Type hints: 必須（関数シグネチャ）

## Import Order (isort compatible)
1. Standard library
2. Third-party
3. Local application

## Naming (PEP8)
- Variables/Functions: snake_case
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE
- Private: _leading_underscore

## Modern Python
- f-strings を優先（.format() は避ける）
- pathlib > os.path
- dataclasses / Pydantic を活用
- Type narrowing with `isinstance()` or `TypeGuard`
