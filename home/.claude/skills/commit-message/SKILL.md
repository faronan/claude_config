---
name: commit-message
description: |
  Generate and execute git commits following Conventional Commits.
  Auto-invoke when: "commit", "コミット", staging changes, or after completing a feature.
---

# Commit Message Skill

## Workflow
1. `git diff --staged` で変更内容を確認（未ステージなら `git status` を案内）
2. 変更内容を分析し、適切な type と scope を決定
3. メッセージを生成して表示
4. ユーザー承認後に `git commit` を実行

## Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

## Type Reference
| Type | 用途 | Emoji (optional) |
|------|------|------------------|
| feat | 新機能 | ✨ |
| fix | バグ修正 | 🐛 |
| docs | ドキュメント | 📝 |
| style | フォーマット | 🎨 |
| refactor | リファクタリング | ♻️ |
| perf | パフォーマンス | ⚡ |
| test | テスト | ✅ |
| chore | 雑務 | 🔧 |
| ci | CI設定 | 👷 |

## Rules
- subject: 50文字以内、現在形、末尾ピリオドなし
- body: 「なぜ」を説明、72文字折り返し
- 日本語メッセージでも type は英語
- Breaking change: `!` を付与 (例: `feat!:`)

## Examples
```
feat(auth): GitHubのOAuth2認証を追加

既存のパスワード認証と併用可能なGitHub OAuthを実装。
ユーザーはGitHubアカウントを連携できるようになった。

Closes #123
```
