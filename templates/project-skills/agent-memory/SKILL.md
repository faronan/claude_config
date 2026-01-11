---
name: agent-memory
description: |
  Save and recall context, decisions, and progress across sessions.
  Use when the user wants to save work progress, remember decisions, or resume interrupted work.
  Trigger words: "記憶して", "保存して", "思い出して", "覚えて", "メモして",
  "remember", "save context", "recall", "what did we decide", "resume work".
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - "Bash(mkdir -p:*memories*)"
---

# Agent Memory Skill

セッションを跨いで文脈・決定事項・進捗を永続化するスキル。

## 機能

### 1. 記憶の保存（Save）

ユーザーが「記憶して」「保存して」と指示した場合:

1. 現在の作業内容・決定事項を要約
2. `memories/` フォルダにマークダウンファイルとして保存
3. ファイル名: `YYYY-MM-DD-{slug}.md`

**フォーマット:**
```markdown
---
summary: "簡潔な要約（検索用）"
created: YYYY-MM-DD
tags:
  - investigation
  - decision
---

## Context
何についての記憶か

## Content
詳細な内容

## Next Steps
次にやるべきこと（あれば）
```

### 2. 記憶の想起（Recall）

ユーザーが「思い出して」「○○について何か覚えてる？」と指示した場合:

1. `memories/` フォルダ内の `summary:` フィールドを検索
2. 関連するファイルを特定
3. 必要なファイルのみ読み込んで文脈を復元

**検索コマンド例:**
```bash
rg "summary:.*キーワード" memories/
```

## 使用例

### 記憶の保存
```
ユーザー: この調査結果を記憶して
Claude: memories/2025-01-11-authentication-investigation.md に保存しました
```

### 記憶の想起
```
ユーザー: 認証周りの調査結果を思い出して
Claude: 2025-01-11 に保存した認証調査の記録を見つけました...
```

## Setup

プロジェクトの `.claude/skills/` にこのフォルダをコピー:

```bash
cp -r templates/project-skills/agent-memory .claude/skills/
mkdir -p .claude/skills/agent-memory/memories
```

## Notes

- memories/ は .gitignore に追加済み（個人の作業メモのため）
- チーム共有したい場合は .gitignore から除外
- 定期的に古い記憶を整理することを推奨
