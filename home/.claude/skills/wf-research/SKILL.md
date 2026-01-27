---
name: wf-research
argument-hint: "[research topic]"
description: Execute research workflow combining codebase analysis and web research.
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - Task
  - mcp__context7__*
---

# Research Workflow

指定された質問に対して、コードベース調査とWeb調査を組み合わせて回答する。

## Arguments

- `$ARGUMENTS`: 調査したい質問・トピック

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Codebase Research (researcher agent)                │
│     └→ コードベース内の関連情報を調査                   │
├─────────────────────────────────────────────────────────┤
│  2. Web Research (web-research skill)                   │
│     └→ 外部ドキュメント・ベストプラクティスを調査       │
├─────────────────────────────────────────────────────────┤
│  3. Synthesis                                           │
│     └→ 調査結果を統合してレポート                       │
└─────────────────────────────────────────────────────────┘
```

## Step Details

### 1. Codebase Research Phase

researcher agent を使用:
- 関連ファイルの特定
- 既存の実装パターンの発見
- 依存関係の分析
- 影響範囲の調査

### 2. Web Research Phase

web-research skill を使用:
- 公式ドキュメントの参照（Context7 MCP）
- 最新のベストプラクティス調査
- ライブラリ・ツールの比較（該当時）

### 3. Synthesis Phase

調査結果を統合:
- 発見事項のまとめ
- コードベースの現状と外部情報の比較
- 推奨アクションの提示

## Output Format

```markdown
## 調査結果: [トピック]

### コードベース分析

- 関連ファイル: [リスト]
- 現状の実装: [説明]
- 既存パターン: [説明]

### 外部調査

- ベストプラクティス: [説明]
- 参照元: [ソースリスト]

### 推奨アクション

1. [アクション1]
2. [アクション2]
```

## Notes

- コードベース調査を先に行い、外部調査の焦点を絞る
- 情報のソースを必ず明記
- 不明点は明示する
