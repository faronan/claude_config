---
name: workflow-research
argument-hint: "[research topic]"
description: |
  Execute research workflow combining codebase analysis and web research.
  Trigger words: "調査ワークフロー", "技術調査", "research workflow", "分析して", "コードベース調査".
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - mcp__context7__*
---

# Research Workflow

指定された質問に対して、コードベース調査とWeb調査を組み合わせて回答する。

## Codex Runtime

Follow `../CODEX_COMPATIBILITY.md`. In Codex, research locally by default. Use
`spawn_agent` only when the user explicitly asks for sub-agents, delegation, or
parallel agent work. Use the available web tools for current information.

## Arguments

- `$ARGUMENTS`: 調査したい質問・トピック

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Codebase Research                                  │
│     └→ コードベース内の関連情報を調査                   │
├─────────────────────────────────────────────────────────┤
│  2. Web Research                                       │
│     └→ 外部ドキュメント・ベストプラクティスを調査       │
├─────────────────────────────────────────────────────────┤
│  3. Synthesis                                           │
│     └→ 調査結果を統合してレポート                       │
└─────────────────────────────────────────────────────────┘
```

## Step Details

### 1. Codebase Research Phase

コードベースを調査:

- 関連ファイルの特定
- 既存の実装パターンの発見
- 依存関係の分析
- 影響範囲の調査

### 2. Web Research Phase

Web 調査を実行:

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

## Completion Criteria

以下をすべて満たした時点で完了:

- [ ] コードベース分析が完了
- [ ] 外部調査が完了
- [ ] レポートがまとまっている
- [ ] 推奨アクションが明記されている

## Optional Codex Sub-Agent Roles

- ユーザーが明示的に委譲を求めた場合のみ、コード調査・Web 調査に対応する Codex sub-agent を使う。

## Error Handling

- **コードベースに関連情報がない**: 外部調査の比重を上げ、類似プロジェクトの事例を調査
- **Web検索で有用な情報が見つからない**: 検索キーワードを変更し、公式ドキュメントやGitHub Issuesに範囲を拡大
- **調査結果が矛盾する**: 情報源の信頼性を評価し、矛盾点を明記してユーザーに判断を委ねる
