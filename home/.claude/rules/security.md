# Security Checklist

このルールは全ファイルに適用される（paths指定なし）。

## Input Validation
- [ ] ユーザー入力は全てバリデーション
- [ ] SQLインジェクション対策（パラメータ化クエリ）
- [ ] XSS対策（エスケープ、CSP）

## Authentication & Authorization
- [ ] 認証チェックは適切な箇所で実施
- [ ] 認可チェック（リソースへのアクセス権）
- [ ] セッション管理（有効期限、再生成）

## Secrets
- [ ] ハードコードされた秘密情報がないこと
- [ ] 環境変数 or Secret Manager を使用
- [ ] ログに機密情報を出力しない

## Dependencies
- [ ] 既知の脆弱性がないこと
- [ ] 最小権限の原則
