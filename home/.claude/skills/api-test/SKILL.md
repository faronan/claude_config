---
name: api-test
argument-hint: "[METHOD URL JSON_BODY]"
context: fork
description: |
  Test API endpoints using jq pipeline to avoid shell escaping issues.
  Use when the user asks to test APIs, verify endpoints, or run curl commands with JSON.
  Trigger words: "API", "curl", "REST", "動作確認", "エンドポイント", "APIテスト",
  "リクエスト", "レスポンス", "POST", "GET", "叩いて", "確認して", "ヘルスチェック".
allowed-tools:
  - Bash(jq:*)
  - Bash(curl:*)
---

# API Test Skill

## Purpose
- APIエンドポイントの動作確認
- JSONペイロードを含むHTTPリクエストの送信
- シェルエスケープ問題を回避した安全なcurl実行

## Core Pattern

```bash
# 基本形（一時ファイル不要）
jq -n '{name: "John", email: "john@example.com"}' | \
  curl -s -X POST -H "Content-Type: application/json" -d @- URL

# 動的な値を使う場合
jq -n --arg name "$NAME" --arg email "$EMAIL" '{name: $name, email: $email}' | \
  curl -s -X POST -H "Content-Type: application/json" -d @- URL

# レスポンスをjqで整形
curl -s URL | jq .
```

## Workflow

1. **コンテキスト解析**
   - 会話やコードベースからURL、メソッド、ボディを推測
   - 引数があればそれを優先

2. **jqコマンド構築**
   - JSONペイロードを `jq -n '{...}'` で構築
   - 変数がある場合は `--arg` オプションを使用

3. **パイプライン実行**
   - `jq | curl -d @-` パターンで実行（一時ファイル不要）
   - 適切なHTTPメソッドとヘッダーを設定

4. **レスポンス整形**
   - JSONレスポンスは `jq .` で整形して表示
   - ステータスコードも `-w '\n%{http_code}'` で確認

## HTTP Methods

```bash
# GET
curl -s URL | jq .

# POST with JSON
jq -n '{key: "value"}' | curl -s -X POST -H "Content-Type: application/json" -d @- URL | jq .

# PUT
jq -n '{key: "updated"}' | curl -s -X PUT -H "Content-Type: application/json" -d @- URL | jq .

# DELETE
curl -s -X DELETE URL | jq .
```

## Examples

```bash
# ヘルスチェック
curl -s http://localhost:3000/health | jq .

# ユーザー作成
jq -n '{name: "Taro", email: "taro@example.com"}' | \
  curl -s -X POST -H "Content-Type: application/json" -d @- \
  http://localhost:3000/api/users | jq .

# 認証付きリクエスト
jq -n '{query: "test"}' | \
  curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d @- URL | jq .

# ステータスコード確認
curl -s -o /dev/null -w '%{http_code}' URL
```

## Guidelines

- **一時ファイルを作成しない**: 常に `jq | curl -d @-` パイプラインを使用
- **JSONは必ずjqで構築**: シェルエスケープ問題を回避
- **レスポンスは整形**: `| jq .` でJSONを見やすく
- **エラー時**: HTTPステータスコードとレスポンスボディを確認

## Error Handling

- **タイムアウト**: `-m` オプションでタイムアウト値を設定し、リトライを検討
- **ネットワークエラー**: URL の到達性を確認（`curl -I` でヘッダのみ取得して確認）
- **認証エラー (401/403)**: トークン・認証情報の有効性を確認
- **JSON パースエラー**: レスポンスが JSON かどうか Content-Type を確認
