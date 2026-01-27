---
name: handoff
description: Summarize session progress for handoff to next session
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash(git log:*)
  - Bash(git status:*)
  - Bash(git branch:*)
---

# Session Handoff

現在のセッションの進捗をまとめ、次のセッションへの引継ぎ情報を生成する。

## Session Context
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`
- Uncommitted changes: !`git status --short`

## Output Content

1. **完了したこと**: 今セッションで完了したタスク
2. **現在の状態**: ファイルの変更状況、テスト結果
3. **次のステップ**: 残りのタスク、推奨アクション
4. **注意点**: 未解決の問題、ブロッカー

## Output Format

```markdown
# Session Handoff

## Completed
- [完了タスク1]
- [完了タスク2]

## Current State
- 変更ファイル: [リスト]
- テスト状態: [PASS/FAIL]
- ビルド状態: [OK/NG]

## Next Steps
1. [ ] [次のタスク1]
2. [ ] [次のタスク2]

## Notes
- [注意点や未解決の問題]

---
*Generated at: [timestamp]*
```
