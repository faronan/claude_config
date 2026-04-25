---
name: empirical-prompt-tuning
argument-hint: "[target prompt path or skill name]"
description: |
  Iteratively improve agent-facing instructions (skills, slash commands, task prompts,
  CLAUDE.md sections) by dispatching unbiased subagents to execute them and evaluating
  on dual axes (executor self-report + dispatcher metrics). Stop when improvement plateaus.
  Use after creating or significantly revising a prompt, or when an agent's behavior
  diverges from expectations and ambiguity in the instruction is suspected.
  Trigger words: "empirical tuning", "プロンプト改善", "スキル評価", "反復改善",
  "skill tuning", "prompt evaluation", "subagent 評価", "プロンプトチューニング".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Agent
  - AskUserQuestion
---

# Empirical Prompt Tuning

プロンプトの品質は書いた本人には判断できない。直前に書いた文章は構造的に客観視不能。
**バイアスを排した別 subagent に実際に動かしてもらい、両面（自己申告 + 指示側メトリクス）で評価して反復する** のが本 skill の核。改善が頭打ちになるまで止めない。

## When to Use / Not to Use

使う場面:

- skill / slash command / タスクプロンプトを新規作成・大幅改訂した直後
- agent が期待通り動かず、原因を指示側の曖昧さに求めたいとき
- 重要度の高い指示（頻繁に使う skill、自動化の中核プロンプト）を堅牢化したいとき

使わない場面:

- 一回限りの使い捨てプロンプト（評価コストが割に合わない）
- 成功率改善ではなく書き手の主観的好みを反映したいだけのとき

## Workflow

### Iter 0: description ↔ body 整合チェック（dispatch 不要）

- frontmatter `description` の謳う trigger / 用途を読む
- body がカバーする範囲を読む
- 乖離があれば iter 1 に進む前に description か body を合わせる
- これを飛ばすと subagent は description に合わせて body を再解釈し、実質要件未達なのに精度が出る（false positive）

### 1. ベースライン準備

次の 2 つを用意:

- **評価シナリオ** 2-3 種（中央値 1 + edge 1-2）。現実の使用場面を想定する
- **要件チェックリスト**（精度算出用）。シナリオごとに「成果物が満たすべき要件」を 3-7 項目で列挙
  - `[critical]` タグ付き項目を **最低 1 つ** 含める（0 件だと成功判定が vacuous になる）
  - 事前に固定し、後から動かさない（過適合防止）

### 2. バイアス排除読み

`Agent` ツールで **新規 subagent を dispatch** する。自己再読で代替しない。
並列で複数シナリオを同時実行する場合、単一メッセージ内で複数 Agent 呼び出しを並べる。
dispatch 不能な環境では「Environment Constraints」節を参照。

### 3. 実行

`references/subagent-contract.md` の起動契約に従ったプロンプトを subagent に渡し、シナリオを実行させる。
実行者は成果物 + 自己申告レポートを返す。

### 4. 両面評価

戻ってきた結果から次を記録:

- **自己申告**（subagent レポート本文から抽出）: 不明瞭点 / 裁量補完 / テンプレ適用で詰まった箇所
- **Trace 解釈**: 各不明瞭点に発生フェーズタグ（Understanding / Planning / Execution / Formatting）を付ける。フェーズ局所修正の方が「指示が不明瞭」と片付けるより効く
- **構造化振り返り**: 各不明瞭点を `Issue / Cause / General Fix Rule` の 3 点で返させる
  - `General Fix Rule` は失敗パターン台帳（`references/failure-pattern-ledger.md`）に供給するクラスレベルの抽象化
- **指示側メトリクス**:
  - 成功/失敗: `[critical]` 項目が **全て ○** のときのみ ○
  - 精度: ○=満点, ×=0, 部分的=0.5 で合算 / 全項目数
  - ステップ数: Agent 戻り値の usage メタ `tool_uses`（Read/Grep も含める）
  - 所要時間: usage メタの `duration_ms`
  - 再試行回数: subagent 自己申告から抽出
  - 失敗時は「どの [critical] が落ちたか」を 1 行添える

### 5. 差分適用

不明瞭点を潰す最小修正をプロンプトに入れる。**1 イテレーション 1 テーマ**（関連する 2-3 件の微修正は 1 iter にまとめて良い）。

- 修正前に「この修正が要件チェックリスト / 判定文言のどの項目を満たすか」を明示する
- まず失敗パターン台帳を参照する。`General Fix Rule` が既存エントリと一致するなら、最初に問うべきは「既存修正はなぜ再発を防げなかったか」

### 6. 再評価

新しい subagent で 2 → 5 を繰り返す。**同一 agent は再利用しない**（前回の改善を学習している）。

### 7. 収束判定

連続 2 回で次を **全て** 満たせば停止:

- 新規不明瞭点: 0 件
- 精度の前回比改善: +3 ポイント以下（飽和）
- ステップ数の前回比変動: ±10% 以内
- duration の前回比変動: ±15% 以内
- **過適合チェック**: hold-out シナリオ 1 本を追加評価。直近平均から精度が 15 ポイント以上落ちたら過適合 → baseline シナリオに edge を足す

重要度の高いプロンプトは 3 連続にする。

## Evaluation Axes

| 軸           | 取り方                 | 意味                   |
| ------------ | ---------------------- | ---------------------- |
| 成功/失敗    | `[critical]` 全 ○ で ○ | 最低ライン             |
| 精度         | 要件達成率 %           | 部分成功の程度         |
| ステップ数   | `tool_uses`            | 指示の無駄遣いの指標   |
| 所要時間     | `duration_ms`          | 認知負荷の代替指標     |
| 再試行回数   | 自己申告               | 指示の曖昧さのシグナル |
| 不明瞭点     | 自己申告（箇条書き）   | 質的な改善材料         |
| 裁量補完箇所 | 自己申告               | 暗黙の仕様の炙り出し   |

**重み付け**: 質的（不明瞭点・裁量補完）を主、量的（時間・ステップ数）を補助。時間短縮だけ追いかけるとプロンプトが痩せすぎる。

### tool_uses の質的解釈

シナリオ間で他比 **3-5 倍以上** なら、その skill は **decision-tree index 寄りで自己完結性が低い** サイン。実行者が references descent を強いられている。
対処: SKILL.md 冒頭に最小完成例 inline / references を読むタイミングの指針を追加。

精度 100% でも `tool_uses` の偏りがあれば iter 続行の根拠になる。

### 修正の波及パターン

修正→効果は線形ではない。詳細は `references/red-flags.md` の「修正の波及パターン」節を参照。

## Output Format

各イテレーションで次の形で記録:

```
## Iteration N

### 変更点（前回差分）
- <修正内容 1 行>
- Pattern applied: <台帳上の Pattern 名、または「(new)」>

### 実行結果（シナリオ別）
| シナリオ | 成功/失敗 | 精度 | steps | duration | retries | Weak phase |
|---|---|---|---|---|---|---|
| A | ○ | 90% | 4 | 20s | 0 | — |
| B | × | 60% | 9 | 41s | 2 | Execution |

### 構造化振り返り（今回新出）
- <シナリオ B>: [critical] 項目 N が × — <落ちた理由 1 行>
  - Issue: <観測現象>
  - Cause: <指示レベルの原因>
  - General Fix Rule: <クラスレベルの抽象化>

### 裁量補完（今回新出）
- <シナリオ B>: <補完内容>

### 台帳更新
- Added: <Pattern 名>（シナリオ B 由来）
- Re-seen: <Pattern 名>（元々 iter K） — 既存修正が再発を防げなかった理由: <理由>

### 次の修正案
- <最小修正 1 行>

（収束判定: 連続 X 回クリア / 停止条件まであと Y 回）
```

## Environment Constraints

新規 subagent を dispatch できない環境（既に subagent として動作中、Agent ツールが無効化されている等）では、本 skill は **適用しない**。

- 代替案 1: 親セッションのユーザーに別 Claude Code セッションでの依頼を促す
- 代替案 2: 評価を諦め、ユーザーに `empirical evaluation skipped: dispatch unavailable` と明示報告
- **NG**: 自己再読で代替する（バイアスが入るため評価結果を信じてはいけない）

**構造審査モード**: empirical 評価ではなく、**記述の整合性・明瞭性だけ** をチェックしたい場合は subagent への依頼に「今回は構造審査モード: 実行ではなくテキスト整合性チェック」と明記する。連続クリア判定には使えない補助。

## Error Handling

- **dispatch 不能**: Environment Constraints のフォールバックに従う
- **3 回以上不明瞭点が減らない**: プロンプト設計方針が間違っている可能性 → 修正パッチをやめ、構造を書き直す
- **過適合検出**: hold-out で精度が 15 ポイント以上落ちた場合、baseline シナリオに edge を追加
- **同じ Pattern が 3 回以上再発**: 構造シグナル → 「発散」基準にエスカレート

## Notes

- 詳細は references/ を参照:
  - subagent 起動契約テンプレ: `${CLAUDE_SKILL_DIR}/references/subagent-contract.md`
  - 失敗パターン台帳: `${CLAUDE_SKILL_DIR}/references/failure-pattern-ledger.md`
  - Red flags / よくある失敗 / バリアント探索: `${CLAUDE_SKILL_DIR}/references/red-flags.md`
- 関連 skill:
  - `skill-creation`: 新規スキル生成。生成直後・大幅改訂後に本 skill を回す
  - `workflow-tdd`: コード TDD。本 skill はプロンプト TDD（探索 → 評価 → 修正 → 再評価）
