---
name: mcp-guidance
description: |
  Guidance for selecting and using MCP servers effectively.
  Auto-invoke when: choosing between MCPs, "どのMCPを使う", optimizing tool usage.
  Covers: context7, sequential-thinking, playwright.
allowed-tools:
  - mcp__context7__*
  - mcp__sequential-thinking__*
  - mcp__playwright__*
---

# MCP Server ガイダンス

## MCP vs Skills の役割分担

| 役割 | MCP | Skills |
|------|-----|--------|
| 提供するもの | 接続性（データアクセス） | 専門知識（手順・判断） |
| 例え | 店へのアクセス | 何を買うかの知識 |

**原則**: MCP は「どうやって接続するか」、Skills は「どう使うか・何を判断するか」

---

## Context7 MCP

### いつ使うか
- ライブラリの**公式ドキュメント**が必要な時
- フレームワークの**ベストプラクティス**を確認したい時
- **バージョン固有**の API を調べる時

### いつ使わないか
- 一般的なプログラミング知識で十分な時
- ドキュメントより実際のコードを読むべき時

### 使用例
```
✅ "React useEffect の公式パターンを確認"
✅ "Next.js 14 の App Router 設定方法"
✅ "Prisma のリレーション定義方法"
❌ "for ループの書き方"（一般知識で十分）
```

### Workflow
1. `resolve-library-id` でライブラリ ID を取得
2. `get-library-docs` で該当トピックを取得
3. 取得した情報を実装に適用

---

## Sequential Thinking MCP

### いつ使うか
- **複雑な推論**が必要な時（多段階の分析、トレードオフ評価）
- **仮説検証**を繰り返す時
- 思考プロセスを**明示的に構造化**したい時

### いつ使わないか
- 単純な実装タスク
- 答えが明確な質問

### 使用例
```
✅ "このアーキテクチャの長所短所を分析"
✅ "バグの根本原因を特定"
✅ "複数の実装案を比較評価"
❌ "この関数を実装して"（直接実装可能）
```

### Workflow
1. 問題を定義
2. `sequentialthinking` で段階的に分析
3. 各ステップで仮説を立て検証
4. 結論を導出

---

## GitHub MCP

### いつ使うか
- **PR/Issue の操作**（作成、更新、コメント）
- **リポジトリ情報**の取得
- **GitHub Actions** の確認

### いつ使わないか
- ローカル git 操作（`git` コマンドを使用）
- 単純なファイル読み書き

### 使用例
```
✅ "Issue #123 の詳細を確認"
✅ "PR を作成してレビュー依頼"
✅ "GitHub Actions のステータス確認"
❌ "git commit"（ローカル git コマンド）
```

---

## 選択フローチャート

```
タスク開始
    │
    ├─ ドキュメント参照が必要？ ─→ Context7
    │
    ├─ 複雑な分析・推論が必要？ ─→ Sequential Thinking
    │
    ├─ GitHub リモート操作が必要？ ─→ GitHub MCP
    │
    └─ 上記以外 ─→ Claude Code ネイティブツール
```

## 組み合わせパターン

| シナリオ | 組み合わせ |
|---------|-----------|
| 新ライブラリ導入判断 | Context7（調査）→ Sequential（比較分析） |
| バグ修正 PR 作成 | Sequential（原因分析）→ GitHub（PR作成） |
| フレームワーク移行 | Context7（新旧ドキュメント）→ Sequential（計画策定） |
