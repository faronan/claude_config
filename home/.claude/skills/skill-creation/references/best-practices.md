# Skill Best Practices

## 公式ベストプラクティス

### 1. 明確な目的

- 1つのスキルは1つの明確な目的を持つ
- description に「いつ使うか」を明記

### 2. トリガーワードの設定

- 日本語・英語の両方を含める
- ユーザーが自然に使うフレーズを選ぶ
- description 内に `Trigger words:` で列挙

### 3. allowed-tools の整合性

- Workflow で使用する全ツールを listed する
- 不要なツールは含めない（最小権限の原則）
- エージェント委譲の場合は `agent:` フィールドを使用

### 4. Progressive Disclosure

- メインの SKILL.md は 500行以下に保つ
- 詳細な参照情報は `references/` ディレクトリに分離
- 本文から `references/xxx.md を参照` でリンク

### 5. セクション標準構成

推奨セクション順序:

1. Purpose（スキルの目的）
2. Arguments（引数の説明）
3. Context（自動収集する情報）
4. Workflow（実行手順）
5. Output Format（出力形式）
6. Guidelines（ガイドライン）
7. Error Handling（エラー対応）
8. Notes（補足情報）
9. Agent References（エージェント参照）

全セクションが必須ではない。スキルに応じて必要なものを選択。

### 6. Error Handling

- 想定されるエラーケースを列挙
- 各エラーに対する具体的な対応方法を記述

### 7. コンテキスト設定

- `context: fork` — 独立したコンテキストで実行（読み取り専用タスクに適切）
- `context:` 省略 — 親コンテキストを共有（状態変更を伴うタスクに適切）
- `disable-model-invocation: true` — ユーザーが直接呼び出すワークフローに使用

## 本リポジトリの規約

### 言語

- コード・frontmatter: 英語
- Workflow 説明・コメント: 日本語
- description: 英語メイン + 日本語トリガーワード

### ファイル構成

```
skills/<skill-name>/
  SKILL.md              # メイン定義（必須）
  references/           # 詳細参照（任意）
    *.md
```

### frontmatter 必須フィールド

- `name`: スキル名（kebab-case）
- `description`: 説明 + トリガーワード

### frontmatter 任意フィールド

- `argument-hint`: 引数のヒント
- `allowed-tools`: 使用ツール
- `context`: コンテキスト設定
- `agent`: 委譲先エージェント
- `disable-model-invocation`: モデル起動の無効化
- `user-invocable`: ユーザー呼び出し可否
