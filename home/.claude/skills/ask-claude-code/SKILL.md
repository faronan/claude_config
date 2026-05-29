---
name: ask-claude-code
effort: medium
argument-hint: "question about Claude Code/API/SDK"
context: fork
agent: claude-code-guide
description: |
  Answer questions about Claude Code CLI, Claude Agent SDK, and Claude API (Anthropic API).
  Use when the user asks about Claude Code features, settings, hooks, MCP, slash commands,
  IDE integrations, Agent SDK usage, or Claude API/SDK implementation.
  Trigger words: "Claude Code", "claude-code", "hooks", "MCP", "settings.json", "CLAUDE.md",
  "Agent SDK", "Anthropic API", "Claude API", "tool use", "スラッシュコマンド", "IDE連携".
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - Bash(gh pr view:*)
  - Bash(gh issue view:*)
  - mcp__context7__*
disallowed-tools:
  - Edit
  - Write
  - MultiEdit
  - NotebookEdit
---

# Claude Code ヘルプ

ユーザーからの質問に回答してください: $ARGUMENTS

## 対象トピック

### Claude Code (CLI)

- 機能・設定（settings.json, CLAUDE.md）
- hooks（PreToolUse, PostToolUse, Stop など）
- スラッシュコマンド（/help, /clear, /compact など）
- MCP サーバー設定・連携
- IDE 統合（VSCode, JetBrains）
- キーボードショートカット
- カスタムエージェント（.claude/agents/）
- カスタムスキル（.claude/skills/）

### Claude Agent SDK

- カスタムエージェントの構築
- Tool 定義とハンドリング
- ワークフロー設計

### Claude API (Anthropic API)

- API の使い方（Messages API）
- Tool use の実装
- Anthropic SDK（Python/TypeScript）の使用法
- ストリーミング、バッチ処理

## 回答ガイドライン

1. **正確性**: 公式ドキュメントや信頼できるソースを参照
2. **具体例**: 設定例やコードサンプルを含める
3. **簡潔さ**: 要点を明確に、冗長な説明を避ける
4. **最新性**: 古い情報に注意し、必要に応じてWeb検索で確認

## 出力フォーマット

```
## 回答

[質問への直接的な回答]

### 設定例 / コード例（該当する場合）
[具体的な例]

### 参考
- [関連ドキュメントや参照元]
```

## Error Handling

- **質問が曖昧**: 具体的なトピック（CLI/API/SDK）を特定するよう聞き返す
- **ドキュメントが見つからない**: WebSearch で最新情報を検索
- **バージョン固有の質問**: 対象バージョンを確認し、Context7 で該当ドキュメントを取得
