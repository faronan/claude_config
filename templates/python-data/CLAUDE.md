# Project: [プロジェクト名]

Python データ分析/機械学習プロジェクト。

## Commands
- `uv run python main.py` - メインスクリプト実行
- `uv run pytest` - テスト実行
- `uv run jupyter lab` - Jupyter Lab 起動
- `ruff check --fix . && ruff format .` - リント＆フォーマット

## Architecture
- `src/` - メインコード
- `notebooks/` - Jupyter ノートブック
- `data/` - データファイル（Git管理外）
- `tests/` - テスト

## Conventions
- 型ヒント必須: `def func(x: int) -> str:`
- docstring: Google スタイル
- インポート: `import pandas as pd`, `import numpy as np`
