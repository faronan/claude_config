# Project: [プロジェクト名]

Python データ分析/機械学習プロジェクト。

## Commands
- `uv run python main.py` - メインスクリプト実行
- `uv run pytest` - テスト実行
- `uv run jupyter lab` - Jupyter Lab 起動
- `ruff check --fix .` - リント
- `ruff format .` - フォーマット

## Code Style
- 型ヒント必須（`def func(x: int) -> str:`）
- docstring は Google スタイル
- pandas は `import pandas as pd`
- numpy は `import numpy as np`

## Architecture
- `src/` - メインコード
- `notebooks/` - Jupyter ノートブック
- `data/` - データファイル（Git 管理外）
- `tests/` - テスト
