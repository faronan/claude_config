---
description: |
  Generate PR description from commits.
  Use when creating a pull request.
  Trigger: "PR", "プルリク", "pull request"
---

1. `git log main..HEAD --oneline` でコミット一覧を取得
2. 各コミットの変更内容を分析
3. pr-description スキルのルールに従って PR 説明文を生成
4. 生成した説明文を表示

$ARGUMENTS があればベースブランチとして使用（デフォルト: main）
