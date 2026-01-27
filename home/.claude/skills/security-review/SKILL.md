---
name: security-review
argument-hint: "[file or directory]"
description: |
  Review code for security vulnerabilities based on OWASP Top 10.
  Use when: security audit, vulnerability check, pre-deployment review.
disable-model-invocation: true
context: fork
agent: security-reviewer
---

# Security Review

指定されたファイルまたはディレクトリのセキュリティレビューを実施する。

## Arguments

- `$ARGUMENTS`: レビュー対象のファイルまたはディレクトリ（省略時: 変更されたファイル）

## Workflow

1. 対象ファイルの特定
2. OWASP Top 10 に基づく脆弱性チェック
3. 発見事項のレポート出力

## Notes

- 読み取り専用（修正は行わない）
- 重大度を明示した発見事項を報告
- 具体的な修正方法を提案
