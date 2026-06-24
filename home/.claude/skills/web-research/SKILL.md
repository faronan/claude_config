---
name: web-research
argument-hint: "[topic or question]"
context: fork
description: |
  Research libraries, frameworks, APIs, and technical solutions from the web.
  Use when the user asks to compare options, find documentation, research a topic, or needs current information.
  Trigger words: "調べて", "research", "比較", "最新の", "どっちがいい", "検索して",
  "教えて", "おすすめ", "何がいい", "ベストプラクティス", "look up", "find out".
allowed-tools:
  - WebFetch
  - WebSearch
  - mcp__context7__*
  - mcp__tavily-remote-mcp__*
  - mcp__tavily__*
disallowed-tools:
  - Edit
  - Write
  - MultiEdit
  - NotebookEdit
  - Bash
---

# Web Research Skill

## Purpose

- ライブラリ・フレームワークの比較検討
- 最新のベストプラクティス調査
- 技術的な問題の解決策検索
- 公式ドキュメントの参照

## Workflow

1. 調査目的を明確化
2. 適切なソースを選択
   - 公式ドキュメント → Context7 MCP
   - 最新情報・比較・複数ソース検索 → Tavily MCP
   - 既知 URL の本文取得 → Tavily extract
   - Tavily unavailable / 未認証 / API key 未設定 → ユーザー確認後に WebSearch / WebFetch fallback
3. 情報を収集・整理
4. 構造化してレポート

## Tavily Usage Policy

- 通常調査は Tavily search / extract を優先する
- crawl / map / research 系の深い探索は、ユーザーが網羅調査を明示した場合だけ使う
- API key や secret を出力しない
- Tavily remote MCP が未認証の場合は `/mcp` で認証するよう案内する
- Tavily が使えない場合は、原因を短く報告してから fallback 使用の確認を取る

## Output Format

```
## 調査結果: [トピック]

### 概要
[1-2文のサマリー]

### 主要な発見
1. ...
2. ...

### 比較表（該当時）
| 項目 | A | B |
|------|---|---|
| ... | ... | ... |

### 推奨
[結論・推奨事項]

### 参照元
- [ソース名](URL)
```

## Guidelines

- 情報のソースを必ず明記
- 最新性に注意（更新日を確認）
- 複数ソースで裏付け

## Error Handling

- **検索結果なし**: 検索キーワードを変えて再検索、または関連トピックで探索
- **WebFetch 失敗**: URL の有効性を確認し、代替ソースを検索
- **情報が古い・矛盾**: 複数ソースで裏付け、最新の公式ドキュメントを優先
