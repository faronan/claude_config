#!/usr/bin/env node

const { execSync } = require("child_process");
const path = require("path");

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);

    const model = data.model?.display_name || "Unknown";
    const currentDir = data.workspace?.current_dir || data.cwd || ".";
    const dirName = path.basename(currentDir);

    // Git ブランチ情報
    const gitInfo = getGitInfo(currentDir);

    // context_window の中にあるトークン情報
    const contextWindow = data.context_window || {};
    const contextWindowSize = contextWindow.context_window_size || 200000;
    const usage = contextWindow.current_usage || {};

    // トークン計算（output_tokensは含まない - コンテキストはinputのみ）
    const totalTokens =
      (usage.input_tokens || 0) +
      (usage.cache_creation_input_tokens || 0) +
      (usage.cache_read_input_tokens || 0);

    // コンテキスト使用率（2.1.6+: 新フィールド使用、フォールバック付き）
    const percentage =
      contextWindow.used_percentage != null
        ? Math.round(contextWindow.used_percentage)
        : Math.min(
            100,
            Math.round((totalTokens / (contextWindowSize * 0.8)) * 100)
          );

    const tokenDisplay = formatTokenCount(totalTokens);

    // コンテキスト使用率の色と警告
    let ctxColor = "\x1b[32m"; // 緑
    let ctxWarning = "";
    if (percentage >= 70) ctxColor = "\x1b[33m"; // 黄
    if (percentage >= 90) ctxColor = "\x1b[31m"; // 赤

    // 200K超過警告（2.0.72+）
    if (data.exceeds_200k_tokens) {
      ctxWarning = " [!200K]";
    }

    // コスト情報
    const cost = data.cost?.total_cost_usd || 0;
    const costDisplay = cost > 0 ? `$${cost.toFixed(4)}` : null;

    // 残りコンテキスト表示（2.1.6+）
    const remainingPct =
      contextWindow.remaining_percentage != null
        ? Math.round(contextWindow.remaining_percentage)
        : null;
    const remainingDisplay =
      remainingPct != null ? `(残${remainingPct}%)` : "";

    // 追加ディレクトリ表示（v2.1.47+: workspace.added_dirs）
    const addedDirs = data.workspace?.added_dirs || [];
    const addedDirsDisplay =
      addedDirs.length > 0
        ? `+${addedDirs.map((d) => path.basename(d)).join(",")}`
        : null;

    // 出力を組み立て
    const parts = [
      `\x1b[36m[${model}]\x1b[0m`,
      dirName,
      addedDirsDisplay,
      gitInfo,
      `${tokenDisplay}`,
      `${ctxColor}${percentage}%${remainingDisplay}${ctxWarning}\x1b[0m`,
      costDisplay,
    ].filter((v) => v != null && v !== "");

    console.log(parts.join(" | "));
  } catch (e) {
    console.log(`[Error] ${e.message}`);
  }
});

function getGitInfo(dir) {
  try {
    // Git リポジトリかどうか確認
    execSync("git rev-parse --git-dir", { cwd: dir, stdio: "pipe" });

    // ブランチ名取得
    const branch = execSync("git branch --show-current", {
      cwd: dir,
      encoding: "utf-8",
      stdio: "pipe",
    }).trim();

    if (!branch) return null;

    // 変更があるかチェック
    const status = execSync("git status --porcelain", {
      cwd: dir,
      encoding: "utf-8",
      stdio: "pipe",
    }).trim();

    const hasChanges = status.length > 0;
    const branchDisplay = hasChanges ? `${branch}*` : branch;
    const branchColor = hasChanges ? "\x1b[33m" : "\x1b[32m"; // 黄 or 緑

    return `${branchColor}${branchDisplay}\x1b[0m`;
  } catch {
    return null;
  }
}

function formatTokenCount(tokens) {
  if (tokens >= 1000000) return `${(tokens / 1000000).toFixed(1)}M`;
  if (tokens >= 1000) return `${(tokens / 1000).toFixed(1)}K`;
  return tokens.toString();
}
