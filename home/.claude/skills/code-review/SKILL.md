---
name: code-review
description: |
  Comprehensive code review for quality, security, and maintainability.
  Auto-invoke when: "レビュー", "review", PR作成前, マージ前, コード変更の確認時.
  Use for all PR reviews.
allowed-tools:
  - Read
  - Grep
  - Glob
---

# Code Review Skill

## Review Checklist (Priority Order)

### 1. Correctness (最優先)
- [ ] ロジックエラー、バグ
- [ ] エッジケースの処理
- [ ] 例外・エラーハンドリング
- [ ] 型の整合性

### 2. Security
- [ ] インジェクション脆弱性
- [ ] 認証・認可の適切性
- [ ] 機密情報の取り扱い
- [ ] 入力バリデーション

### 3. Performance
- [ ] N+1クエリ
- [ ] 不要なループ・再計算
- [ ] メモリリーク
- [ ] 非同期処理の適切性

### 4. Maintainability
- [ ] 命名の明確さ
- [ ] 単一責任原則
- [ ] 重複コード
- [ ] テストの有無・品質

### 5. Style (最低優先)
- [ ] フォーマット規約
- [ ] コメントの適切性

## Output Format
```
## Summary
全体評価: ✅ LGTM / ⚠️ 要修正 / ❌ 要再設計

## Findings

### 🔴 Critical
[ファイル:行] 問題の説明
→ 修正案

### 🟡 Warning
[ファイル:行] 問題の説明
→ 修正案

### 🟢 Suggestion
[ファイル:行] 改善提案
```

## Constraints
- **コードを変更しない**（読み取り専用）
- 軽微なスタイル指摘は最小限に
- 良い点も積極的にコメント
