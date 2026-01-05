---
description: |
  Create branch with Conventional Branch naming from current changes.
---

現在のgit差分を分析し、Conventional Branch形式でブランチ名を生成・作成する。

## Workflow

1. `git status` で現在の状態を確認
2. 変更がある場合、`git diff` (未ステージ) または `git diff --staged` (ステージ済み) で内容を分析
3. 変更内容から適切な type と description を決定
4. ブランチ名を提案してユーザー確認を求める
5. 承認後、`git checkout -b <branch-name>` で作成・切り替え

## Naming Convention

```
<type>/<description>
```

### Type

| Type | 用途 |
|------|------|
| feat | 新機能 |
| fix | バグ修正 |
| refactor | リファクタリング |
| docs | ドキュメント |
| chore | 雑務・設定 |
| test | テスト追加 |
| perf | パフォーマンス改善 |
| ci | CI設定 |

### Description Rules

- kebab-case を使用（例: `user-auth`, `button-click-handler`）
- 簡潔で内容を表す名前（2-4語程度）
- Issue番号は含めない

### Examples

- `feat/oauth-login`
- `fix/button-click-handler`
- `refactor/auth-middleware`
- `docs/api-reference`
- `chore/update-deps`

## Notes

- 既存のブランチ名と重複しないよう確認する
- mainやdevelopにいる場合のみ実行を推奨
- 変更がない場合は、作業内容の説明を求める
