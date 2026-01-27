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
   - 最新情報・比較 → WebSearch
   - 特定ページの詳細 → WebFetch
3. 情報を収集・整理
4. 構造化してレポート

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
