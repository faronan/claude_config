---
name: mermaid-generation
argument-hint: "[diagram type] [target file or module]"
description: |
  Generate Mermaid diagrams from codebase analysis.
  Trigger words: "Mermaid", "ダイアグラム", "クラス図", "シーケンス図", "フローチャート", "ER図", "図を生成", "diagram".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Mermaid Generator

コードベースを分析して Mermaid 記法のダイアグラムを自動生成する。

## Arguments

- `$ARGUMENTS`: `[diagram type] [target]` 形式
  - diagram type（省略可）: classDiagram, sequenceDiagram, flowchart, erDiagram, stateDiagram, graph
  - target: ファイルパス、モジュール名、またはディレクトリ

## Workflow

### 1. ターゲットの分析

対象のファイル/モジュール/ディレクトリを特定:

- ファイル指定 → そのファイルを分析
- ディレクトリ指定 → 配下の主要ファイルを Glob で収集
- モジュール名 → Grep で関連ファイルを特定

### 2. 図種別の判定

`$ARGUMENTS` で指定がない場合、コード構造から推定:

- クラス/インターフェース定義が多い → classDiagram
- 関数呼び出しチェーンが主 → sequenceDiagram
- 条件分岐・フローが主 → flowchart
- DB モデル/スキーマ → erDiagram
- 状態遷移パターン → stateDiagram

### 3. コード構造の解析

Read/Grep でコードを解析:

- クラス: 継承関係、メソッド、プロパティ
- 関数: 呼び出し関係、引数、戻り値
- モデル: フィールド、リレーション
- 状態: 状態と遷移条件

### 4. Mermaid 記法で図を生成

解析結果から Mermaid ダイアグラムを構築:

- 適切なノード・エッジの命名
- 関係性の正確な表現
- 読みやすいレイアウト

### 5. 出力

- **インライン**: コードブロックで直接表示（デフォルト）
- **ファイル**: `--output <path>` 指定時は `.md` ファイルに書き出し

## Diagram Types

| タイプ          | 用途             | 主な解析対象               |
| --------------- | ---------------- | -------------------------- |
| classDiagram    | クラス構造       | class, interface, type     |
| sequenceDiagram | 処理フロー       | 関数呼び出しチェーン       |
| flowchart       | 条件分岐・フロー | if/switch, ワークフロー    |
| erDiagram       | データモデル     | DB スキーマ, ORM モデル    |
| stateDiagram    | 状態遷移         | 状態管理, FSM              |
| graph           | 依存関係         | import/require, モジュール |

## Output Format

````
## [対象名] - [図種別]

```mermaid
[生成されたダイアグラム]
```

### 解説
- [図の読み方や注目ポイント]
````

## Error Handling

- **対象ファイルが見つからない**: パスの存在を確認し、ユーザーに正しいパスを確認
- **図種別の判定が困難**: ユーザーに図種別の選択を求める
- **構造が複雑すぎる**: 主要な要素に絞って生成し、省略した部分を注記
- **サポートされていない言語**: 汎用的な構造解析を試み、限界を明示

## Notes

- 大規模なコードベースでは対象を絞ることを推奨
- 詳細な図種別パターンは `${CLAUDE_SKILL_DIR}/references/diagram-patterns.md` を参照
- 基本テンプレートは `${CLAUDE_SKILL_DIR}/references/mermaid-templates.md` も参照
