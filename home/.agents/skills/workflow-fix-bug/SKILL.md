---
name: workflow-fix-bug
argument-hint: "[bug description]"
description: |
  Execute bug fix workflow with investigation, fix, and verification loop.
  Trigger words: "バグ修正", "バグを直して", "fix bug", "デバッグ", "エラー調査", "不具合修正".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - Bash(pytest:*)
  - Skill
---

# Bug Fix Workflow

指定されたバグに対して、原因調査→修正→検証のループを実行する。

## Codex Runtime

Follow `../CODEX_COMPATIBILITY.md`. In Codex, investigate and fix locally by
default. Use `spawn_agent` only when the user explicitly asks for sub-agents,
delegation, or parallel agent work. `AskUserQuestion` means Plan mode
`request_user_input` or a concise conversational confirmation.

## Arguments

- `$ARGUMENTS`: バグの説明（エラーメッセージ、再現手順など）

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Investigation                                      │
│     └→ エラーを解析、根本原因を特定                     │
├─────────────────────────────────────────────────────────┤
│  2. Fix Implementation                                │
│     └→ 原因に基づいて修正を実装                         │
├─────────────────────────────────────────────────────────┤
│  3. Regression Test (/test-generation)                  │
│     └→ 回帰テストを追加                                 │
├─────────────────────────────────────────────────────────┤
│  4. Verification                                      │
│     └→ テストを実行、修正を確認                         │
├─────────────────────────────────────────────────────────┤
│  5. Loop Decision                                       │
│     ├→ バグ未解決: Step 1 に戻る                        │
│     └→ バグ解決: 完了                                   │
└─────────────────────────────────────────────────────────┘
```

## Step Details

### 1. Investigation Phase

原因を調査:

- エラーメッセージの解析
- 関連ログの収集と分析
- 仮説の立案と検証
- 根本原因の特定

**必要な場合のみ調査結果を報告し、修正への承認を取得:**

- 選択肢: 「修正へ進む」「追加調査」「キャンセル」

### 2. Fix Implementation Phase

修正を実装:

- 特定された原因に基づいて修正
- 最小限の変更で修正（副作用を避ける）
- 関連箇所への影響を考慮

### 3. Regression Test Phase

`/test-generation` スキルを呼び出してテストを作成:

- バグを再現するテストケースを追加
- 修正後にテストがパスすることを確認
- 関連するエッジケースもカバー

### 4. Verification Phase

検証を実行:

- 新規テストの実行
- 既存テストの回帰確認
- 結果サマリーを報告

### 5. Loop Decision

- **バグ未解決 or 新たな問題発生**: 再調査（Step 1 へ）
- **バグ解決 & 全テストパス**: 完了

## Output Format

```markdown
## バグ修正完了: [概要]

### 原因

[特定された根本原因]

### 修正内容

- [ファイル:行] [変更内容]

### 追加したテスト

- [テストケース名]

### 検証結果

- 対象バグ: ✅ 修正確認
- 回帰テスト: ✅ 全パス
```

## Notes

- 原因特定を最優先（推測で修正しない）
- 修正は最小限に（関連しない変更を含めない）
- ループは最大3回まで（超過時はユーザーに相談）

## Completion Criteria

以下をすべて満たした時点で完了:

- [ ] 根本原因が特定されている
- [ ] 修正が実装されている
- [ ] 回帰テストが追加されている
- [ ] 全テストがパス

## Optional Codex Sub-Agent Roles

- ユーザーが明示的に委譲を求めた場合のみ、調査・実装・検証に対応する Codex sub-agent を使う。

## Error Handling

- **再現できないバグ**: ログ・環境情報を収集し、仮説ベースで調査を進める。環境差異が疑われる場合は `git log --oneline -10` で直近の変更を確認
- **修正後も別のテストが失敗**: `git diff` で変更内容を確認し、副作用の原因を特定。解決困難な場合は、ユーザー確認後に変更退避や別アプローチを提案
- **ループ上限（3回）到達**: ユーザーに以下の選択肢を提示:
  1. スコープを縮小して再試行
  2. アプローチを変更して再試行
  3. 現状の変更を保持して手動対応に切り替え
  4. 変更を破棄して中止
