---
name: skill-creator
argument-hint: "[skill name or description]"
description: |
  Build, validate, and package Claude Code skills with best practices.
  Trigger words: "スキル作成", "create skill", "新しいスキル", "skill template", "スキルバリデーション".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash(wc:*)
  - AskUserQuestion
---

# Skill Creator

スキルの構築・検証・パッケージングを支援するメタスキル。

## Arguments

- `$ARGUMENTS`: 作成するスキルの名前または説明

## Workflow

### 1. Template Generation

`$ARGUMENTS` からスキルの雛形を生成:
- 標準テンプレート（frontmatter + セクション構成）に準拠
- セクション順序: Purpose → Arguments → Context → Workflow → Output Format → Guidelines → Error Handling → Notes

### 2. Best Practices Check

生成したスキルを検証:
- **frontmatter バリデーション**: YAML 構文、必須フィールドの存在
- **allowed-tools/Workflow 整合性**: Workflow で言及したツールが allowed-tools に含まれるか
- **Progressive Disclosure**: 500行以下であること（`wc -l` で確認）
- **トリガーワード**: description にトリガーワードが含まれるか
- **セクション構成**: 標準テンプレートに準拠しているか

### 3. User Review

AskUserQuestion で確認:
- 選択肢: 「このまま作成」「修正してから作成」「キャンセル」

### 4. Output

SKILL.md を指定パスに生成/修正

## Output Format

```
## Skill Validation Report

### frontmatter
- [✅/❌] name: 設定済み
- [✅/❌] description: トリガーワード含む
- [✅/❌] allowed-tools: Workflow と整合

### Structure
- [✅/❌] セクション順序: 標準準拠
- [✅/❌] 行数: XXX行（500行以下）

### Issues
- [問題があれば列挙]
```

## Guidelines

- 既存スキルのパターンを参考にする（`skills/*/SKILL.md` を Glob で確認）
- `references/` ディレクトリは必要に応じて作成（Progressive Disclosure）
- argument-hint のクォートに注意（YAML シーケンス解釈を回避）

## Error Handling

- **スキル名が未指定**: AskUserQuestion でスキルの目的を確認
- **同名スキルが既存**: 上書きするか別名にするかを確認
- **allowed-tools に不明なツール**: 利用可能なツール一覧を提示

## Notes

- 詳細なベストプラクティスは `references/best-practices.md` を参照
- frontmatter の仕様は `references/frontmatter-spec.md` を参照
