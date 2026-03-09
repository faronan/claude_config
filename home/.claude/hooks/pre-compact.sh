#!/usr/bin/env bash
# pre-compact.sh - コンパクション前に作業状態を stdout に出力
# stdout の内容がコンパクション時のコンテキストに含まれる

echo "=== Pre-Compact Context ==="

# 変更されたファイルの一覧
if git rev-parse --is-inside-work-tree &>/dev/null; then
  STAGED=$(git diff --cached --name-only 2>/dev/null)
  CHANGED=$(git diff --name-only 2>/dev/null)
  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)

  if [[ -n "$STAGED" || -n "$CHANGED" || -n "$UNTRACKED" ]]; then
    echo ""
    echo "## Modified Files (preserve this list)"
    [[ -n "$STAGED" ]]    && echo "### Staged:"    && echo "$STAGED"
    [[ -n "$CHANGED" ]]   && echo "### Unstaged:"  && echo "$CHANGED"
    [[ -n "$UNTRACKED" ]] && echo "### Untracked:" && echo "$UNTRACKED"
  fi

  # 直近のコミット（何を完了済みか把握するため）
  echo ""
  echo "## Recent Commits"
  git log --oneline -5 2>/dev/null
fi

echo ""
echo "IMPORTANT: Preserve current task goals, completed steps, and next actions."

exit 0
