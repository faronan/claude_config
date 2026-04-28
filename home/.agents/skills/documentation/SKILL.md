---
name: documentation
effort: medium
argument-hint: "[target file or topic]"
description: |
  Generate README, API docs, JSDoc comments, and architecture documentation.
  Use when the user asks to document code, create a README, add comments, or explain usage.
  Trigger words: "ドキュメント", "docs", "README", "説明を書いて", "コメントを追加",
  "使い方", "API仕様", "仕様書", "JSDoc", "docstring", "how to use", "documentation".
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

**テンプレート集**: この skill ディレクトリの `templates.md` を参照

## Error Handling

- **対象コードが見つからない**: パスを確認し、ユーザーに正しい対象を確認
- **既存ドキュメントとの競合**: 既存の内容を確認し、更新か新規作成かを判断
- **言語・フレームワーク不明**: コードベースから自動検出を試み、不明なら質問
