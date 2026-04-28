---
name: security-review
argument-hint: "[file or directory]"
description: |
  Review code for security vulnerabilities based on OWASP Top 10.
  Use when: security audit, vulnerability check, pre-deployment review.
  Trigger words: "セキュリティ", "security", "脆弱性", "OWASP", "セキュリティレビュー", "脆弱性チェック".
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
---

# Security Review

## Codex Runtime

Follow `../CODEX_COMPATIBILITY.md`. In Codex, review locally by default. Use a
security-focused sub-agent only when the user explicitly asks for delegation.

指定されたファイルまたはディレクトリのセキュリティレビューを実施する。

## Arguments

- `$ARGUMENTS`: レビュー対象のファイルまたはディレクトリ（省略時: 変更されたファイル）

## Workflow

1. **対象ファイルの特定**
   - `$ARGUMENTS` が指定されていればそのパスを使用
   - 省略時は `git diff --name-only` で変更されたファイルを対象にする

2. **OWASP Top 10 カテゴリ別チェック**
   - OWASP Top 10 を中心に検査
   - 各カテゴリ（A01〜A10）を順番に確認

3. **依存関係の脆弱性確認**
   - package.json / requirements.txt 等の依存関係ファイルを確認
   - 既知の脆弱性があるパッケージを検出

4. **レポート生成**
   - 発見事項を重大度別（重大/高/中/低）に分類
   - 重大度順に発見事項を報告する

5. **推奨アクションの提示**
   - 優先度順に修正方法を提案

## Output Format

発見事項を重大度順に、根拠となるファイル・行番号と修正案つきで報告する。

## Error Handling

- **対象ファイルが見つからない**: パスの存在を確認し、ユーザーに正しいパスを確認
- **依存関係ファイルがない**: スキップして、コードレベルのレビューに集中
- **git リポジトリ外**: `$ARGUMENTS` の明示的指定を要求

## Notes

- **読み取り専用**: レビューのみ、修正は行わない
- 重大度を明示した発見事項を報告
- 具体的な修正方法を提案
- 委譲はユーザーが明示的に求めた場合のみ行う
