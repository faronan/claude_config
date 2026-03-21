# Frontmatter Specification

## フィールド一覧

### name（必須）

- **型**: string
- **形式**: kebab-case（例: `my-skill`, `code-review`）
- **用途**: スキルの一意識別子

### description（必須）

- **型**: string（複数行は `|` を使用）
- **形式**: 英語の説明 + `Trigger words:` 行
- **例**:
  ```yaml
  description: |
    Review code for bugs and security issues.
    Trigger words: "レビュー", "review", "チェック".
  ```

### argument-hint（任意）

- **型**: string
- **形式**: `"[括弧で囲んだヒント]"`（クォート必須）
- **注意**: YAML シーケンス `[...]` として解釈されないよう、必ずクォートする
- **例**: `"[file or directory]"`

### allowed-tools（任意）

- **型**: sequence of strings
- **形式**: YAML リスト
- **パターン**:
  - 単純ツール: `Read`, `Write`, `Edit`, `Glob`, `Grep`
  - Bash パターン: `Bash(git status:*)`, `Bash(npm run:*)`
  - MCP ツール: `mcp__context7__*`, `mcp__sequential-thinking__*`
  - メタツール: `Task`, `Skill`, `AskUserQuestion`
- **原則**: Workflow で使用するツールのみ含める

### context（任意）

- **型**: string
- **値**: `fork`（独立コンテキスト）
- **省略時**: 親コンテキストを共有
- **使い分け**: 読み取り専用タスク → `fork`、状態変更 → 省略

### agent（任意）

- **型**: string
- **用途**: エージェントに処理を委譲
- **例**: `agent: security-reviewer`

### disable-model-invocation（任意）

- **型**: boolean
- **用途**: `true` でワークフロー型スキルのモデル起動を無効化
- **使い分け**: 複雑なワークフロー → `true`、シンプルなスキル → 省略

### user-invocable（任意）

- **型**: boolean
- **デフォルト**: `true`
- **用途**: `false` で `/skill-name` によるユーザー直接呼び出しを無効化
- **例**: 他スキルから内部的に呼ばれるスキル（commit-message）

## バリデーションルール

1. **name**: kebab-case、ディレクトリ名と一致
2. **description**: 空でないこと
3. **argument-hint**: `[` で始まる場合はクォート必須
4. **allowed-tools**: Workflow で言及されたツールがすべて含まれること
5. **agent**: `agents/` ディレクトリに対応ファイルが存在すること
