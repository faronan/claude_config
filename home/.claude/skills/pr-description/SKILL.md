---
name: pr-description
description: |
  Generate comprehensive PR descriptions.
  Auto-invoke when: "PR", "プルリクエスト", "pull request", creating PRs.
allowed-tools:
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(gh pr create:*)
---

# PR Description Skill

## Workflow

### 1. デフォルトブランチの検出
```bash
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$BASE_BRANCH" ]; then
  BASE_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
fi
```

### 2. コミット履歴の確認
```bash
git log ${BASE_BRANCH}..HEAD --oneline
```

### 3. 差分の分析
```bash
git diff ${BASE_BRANCH}...HEAD --stat
```

### 4. PR説明を生成

## Guidelines
- タイトル: 50文字以内、変更内容を端的に
- 本文: なぜこの変更が必要かを説明
- レビュアーが理解しやすい構成に

**テンプレート**: `template.md` を参照（標準、機能追加、バグ修正、大規模変更用）
