---
description: |
  Run tests and analyze results.
  Use after implementing features or fixing bugs.
  Trigger: "テスト", "test", "テスト実行"
---

1. プロジェクトのテストフレームワークを検出（jest, vitest, pytest 等）
2. $ARGUMENTS があれば対象ファイル/ディレクトリとして使用
3. 指定がなければ関連するテストのみを実行
4. テスト結果を分析し、失敗がある場合は原因と修正案を提示

テストコマンド例:
- `pnpm test` (Node.js)
- `pytest` (Python)
- `cargo test` (Rust)
