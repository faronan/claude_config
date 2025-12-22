---
name: documentation
description: |
  Generate and maintain documentation.
  Auto-invoke when: "ドキュメント", "docs", "README", "JSDoc", API documentation requests.
allowed-tools:
  - Read
  - Glob
  - Write
  - Edit
---

# Documentation Skill

## Documentation Types

### 1. Code Comments
- **When**: 複雑なロジック、非自明な実装理由
- **Format**: JSDoc (TS), docstring (Python)
- **Avoid**: 自明なコードへのコメント

### 2. README.md
プロジェクトの概要、セットアップ手順、使い方を記載。

### 3. API Documentation
- Endpoint, Method, Path
- Request/Response schema
- Error codes
- Examples

### 4. Architecture Documentation
- System overview diagram (Mermaid)
- Component responsibilities
- Data flow

## Style Guide
- 簡潔に、しかし必要な情報は省かない
- 例を含める
- 最新の状態を維持
- 対象読者を意識（初心者/経験者）

**テンプレート集**: `templates.md` を参照
