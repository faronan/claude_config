---
name: security-review
argument-hint: "[file or directory]"
description: |
  Review code for security vulnerabilities based on OWASP Top 10.
  Use when: security audit, vulnerability check, pre-deployment review.
  Trigger words: "セキュリティ", "security", "脆弱性", "OWASP", "セキュリティレビュー", "脆弱性チェック".
disable-model-invocation: true
context: fork
agent: security-reviewer
allowed-tools:
  - Read
  - Glob
  - Grep
---

# Security Review

指定されたファイルまたはディレクトリのセキュリティレビューを実施する。

## Arguments

- `$ARGUMENTS`: レビュー対象のファイルまたはディレクトリ（省略時: 変更されたファイル）

## Workflow

1. **対象ファイルの特定**
   - `$ARGUMENTS` が指定されていればそのパスを使用
   - 省略時は `git diff --name-only` で変更されたファイルを対象にする

2. **OWASP Top 10 カテゴリ別チェック**
   - security-reviewer エージェントのチェックリストに従って検査
   - 各カテゴリ（A01〜A10）を順番に確認

3. **依存関係の脆弱性確認**
   - package.json / requirements.txt 等の依存関係ファイルを確認
   - 既知の脆弱性があるパッケージを検出

4. **レポート生成**
   - 発見事項を重大度別（重大/高/中/低）に分類
   - security-reviewer エージェントの Output Format に従う

5. **推奨アクションの提示**
   - 優先度順に修正方法を提案

## Output Format

security-reviewer エージェントの出力形式に従う（`agent: security-reviewer` で委譲）。

## Error Handling

- **対象ファイルが見つからない**: パスの存在を確認し、ユーザーに正しいパスを確認
- **依存関係ファイルがない**: スキップして、コードレベルのレビューに集中
- **git リポジトリ外**: `$ARGUMENTS` の明示的指定を要求

## Notes

- **読み取り専用**: レビューのみ、修正は行わない
- 重大度を明示した発見事項を報告
- 具体的な修正方法を提案
- 詳細な検査ロジックは security-reviewer エージェントに委譲
