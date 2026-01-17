---
description: Analyze and fix GitHub issue
---

GitHub Issue #$ARGUMENTS を分析して修正する。

1. `gh issue view $ARGUMENTS` で詳細を取得
2. 問題を理解し、関連ファイルを特定
3. 修正計画を提示（planning スキル使用）
4. AskUserQuestion で承認を取得後、実装
   - 選択肢: 「実装開始」「計画を修正」「キャンセル」
5. テスト実行
6. コミット（commit-message スキル使用）
