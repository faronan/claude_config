---
description: Quick commit without confirmation (for small changes)
---

ステージされた変更を確認せずに即座にコミットする。
小さな変更（typo修正、フォーマット等）用。

1. `git diff --staged --stat` で変更ファイル数を確認
2. 変更が3ファイル以下かつ50行以下なら続行、それ以上なら警告
3. commit-message スキルでメッセージ生成
4. 確認なしで `git commit` 実行
