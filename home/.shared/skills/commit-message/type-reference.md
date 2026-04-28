# Commit Type Reference

## Type 一覧

| Type | 用途 | Emoji (optional) |
|------|------|------------------|
| feat | 新機能 | ✨ |
| fix | バグ修正 | 🐛 |
| docs | ドキュメント | 📝 |
| style | フォーマット（機能に影響しない） | 🎨 |
| refactor | リファクタリング | ♻️ |
| perf | パフォーマンス改善 | ⚡ |
| test | テスト追加・修正 | ✅ |
| chore | ビルド、補助ツール | 🔧 |
| ci | CI設定 | 👷 |
| build | ビルドシステム | 📦 |
| revert | コミット取り消し | ⏪ |

## Scope 例

- `auth`: 認証関連
- `api`: API エンドポイント
- `ui`: ユーザーインターフェース
- `db`: データベース
- `config`: 設定ファイル
- `deps`: 依存関係

## 例

### 新機能
```
feat(auth): GitHubのOAuth2認証を追加

既存のパスワード認証と併用可能なGitHub OAuthを実装。
ユーザーはGitHubアカウントを連携できるようになった。

Closes #123
```

### バグ修正
```
fix(api): ユーザー取得時のN+1クエリを解消

eager loadingを適用し、関連データを一括取得するように修正。

Fixes #456
```

### Breaking Change
```
feat!(api): レスポンス形式をJSONAPIに変更

BREAKING CHANGE: 全APIエンドポイントのレスポンス形式が変更されます。
移行ガイド: docs/migration-v2.md
```
