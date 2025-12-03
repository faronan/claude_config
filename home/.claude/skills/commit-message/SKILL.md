---
name: commit-message
description: |
  Generate commit messages following Conventional Commits.
  Use when committing, "git commit", or asking for commit message.
---

# Commit Message Rules

## Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

## Type（必須）
| Type | 用途 |
|------|------|
| feat | 新機能 |
| fix | バグ修正 |
| docs | ドキュメントのみ |
| style | フォーマット（動作に影響なし） |
| refactor | リファクタリング |
| perf | パフォーマンス改善 |
| test | テスト追加・修正 |
| chore | ビルド・補助ツール |
| ci | CI設定 |

## Rules
- subject: 50文字以内、現在形、文末ピリオドなし
- body: 72文字で折り返し、「なぜ」を説明
- 日本語プロジェクトでも type は英語

## Examples
```
feat(auth): add OAuth2 support for GitHub

Implement GitHub OAuth provider alongside existing
password authentication. Users can now link their
GitHub accounts.

Closes #123
```
