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

    // compaction閾値（context_window_sizeの80%）
    const compactionThreshold = contextWindowSize * 0.8;
    const percentage = Math.min(
      100,
      Math.round((totalTokens / compactionThreshold) * 100)
    );

    const tokenDisplay = formatTokenCount(totalTokens);

    // コンテキスト使用率の色
    let ctxColor = "\x1b[32m"; // 緑
    if (percentage >= 70) ctxColor = "\x1b[33m"; // 黄
    if (percentage >= 90) ctxColor = "\x1b[31m"; // 赤

    // コスト情報
    const cost = data.cost?.total_cost_usd || 0;
    const costDisplay = cost > 0 ? ` | $${cost.toFixed(4)}` : "";

    // 出力を組み立て
    const parts = [
      `\x1b[36m[${model}]\x1b[0m`,
      dirName,
      gitInfo,
      `${tokenDisplay}`,
      `${ctxColor}${percentage}%\x1b[0m${costDisplay}`,
    ].filter(Boolean);

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
