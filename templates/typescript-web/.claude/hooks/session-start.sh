#!/bin/bash
# Session initialization hook
# プロジェクト固有の初期化処理をここに記述

# 例: 環境変数の永続化
# if [ -n "$CLAUDE_ENV_FILE" ]; then
#   echo 'export API_BASE_URL=http://localhost:3000' >> "$CLAUDE_ENV_FILE"
# fi

# 例: 前提条件の検証
# if ! command -v node &> /dev/null; then
#   echo "Warning: Node.js is not installed" >&2
# fi

# 例: セッションコンテキストの出力（stdout は Claude のコンテキストに追加される）
# echo "Project initialized at $(date)"

exit 0
