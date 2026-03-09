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

		// Worktree 情報（v2.1.69+: --worktree 使用時に提供される）
		const worktree = data.worktree || null;

		// Git ブランチ情報（worktree 時はそちらを優先）
		const gitInfo = worktree
			? getWorktreeInfo(worktree)
			: getGitInfo(currentDir);

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
		const rawPercentage =
			contextWindow.used_percentage != null
				? contextWindow.used_percentage
				: Math.min(100, (totalTokens / (contextWindowSize * 0.8)) * 100);

		// 実効コンテキスト使用率（compaction 閾値を上限として再計算）
		const compactThreshold = 70; // CLAUDE_AUTOCOMPACT_PCT_OVERRIDE と一致させる
		const effectivePct = Math.min(
			100,
			Math.round((rawPercentage / compactThreshold) * 100),
		);

		const tokenDisplay = formatTokenCount(totalTokens);

		// プログレスバー生成
		const barWidth = 10;
		const filled = Math.round((effectivePct / 100) * barWidth);
		const empty = barWidth - filled;
		const bar = "\u2593".repeat(filled) + "\u2591".repeat(empty);

		// 実効使用率の色分け
		let ctxColor = "\x1b[32m"; // 緑: <60%
		if (effectivePct >= 60) ctxColor = "\x1b[33m"; // 黄: コンパクションが近い
		if (effectivePct >= 85) ctxColor = "\x1b[31m"; // 赤: まもなくコンパクション

		// 200K超過警告（2.0.72+）
		let ctxWarning = "";
		if (data.exceeds_200k_tokens) {
			ctxWarning = " [!200K]";
		}

		// コスト情報
		const cost = data.cost?.total_cost_usd || 0;
		const costDisplay = cost > 0 ? `$${cost.toFixed(4)}` : null;

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
			`${ctxColor}${bar} ${effectivePct}%${ctxWarning}\x1b[0m`,
			costDisplay,
		].filter((v) => v != null && v !== "");

		console.log(parts.join(" | "));
	} catch (e) {
		console.log(`[Error] ${e.message}`);
	}
});

function getWorktreeInfo(worktree) {
	const name = worktree.name || "";
	const branch = worktree.branch || name;
	if (!branch) return null;
	return `\x1b[35m${branch}[wt]\x1b[0m`; // マゼンタで worktree を区別
}

function getGitInfo(dir) {
	try {
		// Git リポジトリかどうか確認（--no-optional-locks で FSEvents ループ防止）
		execSync("git --no-optional-locks rev-parse --git-dir", {
			cwd: dir,
			stdio: "pipe",
		});

		// ブランチ名取得
		const branch = execSync("git --no-optional-locks branch --show-current", {
			cwd: dir,
			encoding: "utf-8",
			stdio: "pipe",
		}).trim();

		if (!branch) return null;

		// 変更があるかチェック
		const status = execSync("git --no-optional-locks status --porcelain", {
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
