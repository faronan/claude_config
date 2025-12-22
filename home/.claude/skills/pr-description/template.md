# PR Description Template

## 標準テンプレート

```markdown
## Summary
<!-- 1-2文で変更の概要を記述 -->


## Changes
<!-- 主な変更点をリスト形式で -->
-
-
-

## Type
<!-- 該当するものにチェック -->
- [ ] feat: 新機能
- [ ] fix: バグ修正
- [ ] docs: ドキュメント
- [ ] refactor: リファクタリング
- [ ] test: テスト追加/修正
- [ ] chore: その他（ビルド、依存関係など）

## Testing
<!-- どのようにテストしたか -->
- [ ] ユニットテスト追加/更新
- [ ] 手動テスト実施
- [ ] E2Eテスト確認

## Screenshots
<!-- UI変更がある場合はスクリーンショットを添付 -->

## Checklist
- [ ] コードは自己レビュー済み
- [ ] 必要なドキュメントを更新した
- [ ] Breaking changeがある場合は明記した

## Related Issues
<!-- 関連するIssueがあれば記載 -->
Closes #
```

---

## 機能追加用テンプレート

```markdown
## Summary
[機能名]を追加しました。

## Motivation
<!-- なぜこの機能が必要か -->


## Changes
-
-

## How to Test
<!-- レビュアーがテストする手順 -->
1.
2.
3.

## Screenshots
| Before | After |
|--------|-------|
| - | [screenshot] |

## Notes for Reviewers
<!-- レビュー時に注目してほしいポイント -->

```

---

## バグ修正用テンプレート

```markdown
## Summary
[バグの概要]を修正しました。

## Root Cause
<!-- バグの原因 -->


## Solution
<!-- どのように修正したか -->


## Regression Test
<!-- 再発防止のためのテスト -->
- [ ] ユニットテスト追加
- [ ] 手動で再現テスト実施

Fixes #
```

---

## 大規模変更用テンプレート

```markdown
## Summary
<!-- 変更の全体像 -->


## Background
<!-- なぜこの変更が必要か、背景情報 -->


## Scope
<!-- 影響範囲 -->
- 変更ファイル数: X
- 影響するコンポーネント:
  - Component A
  - Component B

## Changes

### 1. [変更カテゴリ1]
-
-

### 2. [変更カテゴリ2]
-
-

## Migration Guide
<!-- 利用者への影響と移行手順（必要な場合） -->


## Rollback Plan
<!-- 問題発生時のロールバック手順 -->


## Testing Strategy
- [ ] ユニットテスト
- [ ] インテグレーションテスト
- [ ] E2Eテスト
- [ ] パフォーマンステスト

## Deployment Notes
<!-- デプロイ時の注意事項 -->

```
