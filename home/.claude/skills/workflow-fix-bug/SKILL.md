---
name: workflow-fix-bug
argument-hint: "[bug description]"
description: |
  Execute bug fix workflow with investigation, fix, and verification loop.
  Trigger words: "バグ修正", "バグを直して", "fix bug", "デバッグ", "エラー調査", "不具合修正".
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(npm run:*)
  - Bash(pnpm:*)
  - Bash(pytest:*)
  - Task
  - Skill
  - AskUserQuestion
---

# Bug Fix Workflow

指定されたバグに対して、原因調査→修正→検証のループを実行する。

## Arguments

- `$ARGUMENTS`: バグの説明（エラーメッセージ、再現手順など）

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Investigation (error-investigator agent)            │
│     └→ エラーを解析、根本原因を特定                     │
├─────────────────────────────────────────────────────────┤
│  2. Fix Implementation (implementer agent)              │
│     └→ 原因に基づいて修正を実装                         │
├─────────────────────────────────────────────────────────┤
│  3. Regression Test (/test-generation)                  │
│     └→ 回帰テストを追加                                 │
├─────────────────────────────────────────────────────────┤
│  4. Verification (app-verifier agent)                    │
│     └→ テストを実行、修正を確認                         │
├─────────────────────────────────────────────────────────┤
│  5. Loop Decision                                       │
│     ├→ バグ未解決: Step 1 に戻る                        │
│     └→ バグ解決: 完了                                   │
└─────────────────────────────────────────────────────────┘
```

## Step Details

### 1. Investigation Phase

error-investigator agent を使用:
- エラーメッセージの解析
- 関連ログの収集と分析
- 仮説の立案と検証
- 根本原因の特定

**AskUserQuestion で調査結果を報告し、修正への承認を取得:**
- 選択肢: 「修正へ進む」「追加調査」「キャンセル」

### 2. Fix Implementation Phase

implementer agent を使用:
- 特定された原因に基づいて修正
- 最小限の変更で修正（副作用を避ける）
- 関連箇所への影響を考慮

### 3. Regression Test Phase

`/test-generation` スキルを呼び出してテストを作成:
- バグを再現するテストケースを追加
- 修正後にテストがパスすることを確認
- 関連するエッジケースもカバー

### 4. Verification Phase

app-verifier agent を使用:
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

## Agent References

- **error-investigator**: エラー解析、根本原因特定
- **implementer**: 修正実装
- **app-verifier**: テスト実行、検証

## Error Handling

- **再現できないバグ**: ログ・環境情報を収集し、仮説ベースで調査を進める
- **修正後も別のテストが失敗**: 影響範囲を再調査し、副作用がないか確認
- **ループ上限（3回）到達**: ユーザーに状況を報告し、方針転換を相談
