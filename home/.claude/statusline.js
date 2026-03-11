#!/usr/bin/env node

const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");
const os = require("os");

// Git キャッシュ設定（5秒 TTL でパフォーマンス改善）
const GIT_CACHE_TTL_MS = 5000;
const GIT_CACHE_FILE = path.join(
	os.tmpdir(),
	"claude-statusline-git-cache.json",
);

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

		// Git ブランチ情報（worktree 時はそちらを優先、キャッシュ付き）
		const gitInfo = worktree
			? getWorktreeInfo(worktree)
			: getCachedGitInfo(currentDir);

		// Agent 名表示（--agent フラグ使用時）
		const agentName = data.agent?.name || null;
		const agentDisplay = agentName ? `\x1b[35m@${agentName}\x1b[0m` : null;

		// context_window の中にあるトークン情報
		const contextWindow = data.context_window || {};
		const contextWindowSize = contextWindow.context_window_size || 200000;
		const usage = contextWindow.current_usage || {};

		// トークン計算（output_tokensは含まない - コンテキストはinputのみ）
		const currentTokens =
			(usage.input_tokens || 0) +
			(usage.cache_creation_input_tokens || 0) +
			(usage.cache_read_input_tokens || 0);

		// コンテキスト使用率（3段階フォールバック: used_percentage → total_input_tokens → current_usage）
		const rawPercentage = getRawPercentage(
			contextWindow,
			currentTokens,
			contextWindowSize,
		);

		// 実効コンテキスト使用率（compaction 閾値を上限として再計算）
		const compactThreshold =
			parseInt(process.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE, 10) || 70;
		const effectivePct = Math.min(
			100,
			Math.round((rawPercentage / compactThreshold) * 100),
		);

		const tokenDisplay = formatTokenCount(currentTokens);

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

		// セッション経過時間（Starship: cmd_duration=bold yellow）
		const durationMs = data.cost?.total_duration_ms || 0;
		const durationDisplay =
			durationMs > 0 ? `\x1b[1;33m${formatDuration(durationMs)}\x1b[0m` : null;

		// 行数変更（+/-）
		const linesAdded = data.cost?.total_lines_added || 0;
		const linesRemoved = data.cost?.total_lines_removed || 0;
		const linesDisplay =
			linesAdded > 0 || linesRemoved > 0
				? `\x1b[32m+${linesAdded}\x1b[0m/\x1b[31m-${linesRemoved}\x1b[0m`
				: null;

		// 追加ディレクトリ表示（v2.1.47+: workspace.added_dirs）
		const addedDirs = data.workspace?.added_dirs || [];
		const addedDirsDisplay =
			addedDirs.length > 0
				? `+${addedDirs.map((d) => path.basename(d)).join(",")}`
				: null;

		// === Line 1: Identity + Location ===
		// Identity: Model + Agent
		const identity = [`\x1b[36m[${model}]\x1b[0m`, agentDisplay]
			.filter(Boolean)
			.join(" ");

		// Where: Dir + AddedDirs + Git（Starship: directory=bold cyan）
		const dirDisplay = `\x1b[1;36m${dirName}\x1b[0m`;
		const where = [dirDisplay, addedDirsDisplay, gitInfo]
			.filter(Boolean)
			.join(" ");

		const line1 = [identity, where].filter(Boolean).join(" | ");

		// === Line 2: Context + Metrics ===
		// Context Resources: Tokens + Bar
		const context = `${tokenDisplay} ${ctxColor}${bar} ${effectivePct}%${ctxWarning}\x1b[0m`;

		// Session Metrics: Lines + Cost + Duration
		// コンテキスト 0% 時（/clear 直後等）はセッション累計値を非表示にする
		const metrics =
			effectivePct > 0
				? [linesDisplay, costDisplay, durationDisplay].filter(Boolean).join(" ")
				: "";

		const line2 = [context, metrics].filter((v) => v !== "").join(" | ");

		console.log(line1);
		console.log(line2);
	} catch (e) {
		console.log(`[Error] ${e.message}`);
	}
});

/**
 * コンテキスト使用率の2段階フォールバック
 * 1. used_percentage（v2.1.6+、最も信頼性が高い）
 *    - null でなければ 0 でもそのまま信頼する（/clear 直後は 0 が正しい）
 * 2. current_usage からの計算（最終手段）
 *
 * NOTE: total_input_tokens はセッション累計値のため、現在のコンテキスト使用率の
 * 代替としては使えない（/clear 後に 100% になるバグの原因だった）
 */
function getRawPercentage(contextWindow, currentTokens, contextWindowSize) {
	if (contextWindow.used_percentage != null) {
		return contextWindow.used_percentage;
	}

	if (currentTokens > 0) {
		return Math.min(100, (currentTokens / (contextWindowSize * 0.8)) * 100);
	}

	return 0;
}

function getWorktreeInfo(worktree) {
	const name = worktree.name || "";
	const branch = worktree.branch || name;
	if (!branch) return null;
	// Starship git_branch 準拠: bold purple +  アイコン、worktree は [wt] で区別
	return `\x1b[1;35m\ue0a0 ${branch}\x1b[0m\x1b[1;35m[wt]\x1b[0m`;
}

/**
 * Git 情報をキャッシュ付きで取得（5秒 TTL）
 */
function getCachedGitInfo(dir) {
	try {
		const cache = readGitCache(dir);
		if (cache) return cache.value;

		const result = getGitInfo(dir);
		writeGitCache(dir, result);
		return result;
	} catch {
		return getGitInfo(dir);
	}
}

function readGitCache(dir) {
	try {
		const raw = fs.readFileSync(GIT_CACHE_FILE, "utf-8");
		const cache = JSON.parse(raw);
		if (cache.dir === dir && Date.now() - cache.timestamp < GIT_CACHE_TTL_MS) {
			return cache;
		}
	} catch {
		// cache miss
	}
	return null;
}

function writeGitCache(dir, value) {
	try {
		fs.writeFileSync(
			GIT_CACHE_FILE,
			JSON.stringify({ dir, value, timestamp: Date.now() }),
		);
	} catch {
		// ignore write errors
	}
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

		// 変更があるかチェック（Starship git_status 準拠: bold red [status]）
		const status = execSync("git --no-optional-locks status --porcelain", {
			cwd: dir,
			encoding: "utf-8",
			stdio: "pipe",
		}).trim();

		// Starship git_branch 準拠:  アイコン + bold purple
		let result = `\x1b[1;35m\ue0a0 ${branch}\x1b[0m`;

		// Starship git_status 準拠: bold red [markers]
		if (status.length > 0) {
			const markers = parseGitStatus(status);
			result += ` \x1b[1;31m[${markers}]\x1b[0m`;
		}

		return result;
	} catch {
		return null;
	}
}

function parseGitStatus(status) {
	const lines = status.split("\n");
	let modified = 0;
	let added = 0;
	let deleted = 0;
	let untracked = 0;

	for (const line of lines) {
		const x = line[0];
		const y = line[1];
		if (x === "?" || y === "?") untracked++;
		else if (x === "A" || y === "A") added++;
		else if (x === "D" || y === "D") deleted++;
		else if (x === "M" || y === "M" || x === "R" || y === "R") modified++;
	}

	const parts = [];
	if (modified > 0) parts.push(`!${modified}`);
	if (added > 0) parts.push(`+${added}`);
	if (deleted > 0) parts.push(`-${deleted}`);
	if (untracked > 0) parts.push(`?${untracked}`);

	return parts.join("");
}

function formatTokenCount(tokens) {
	if (tokens >= 1000000) return `${(tokens / 1000000).toFixed(1)}M`;
	if (tokens >= 1000) return `${(tokens / 1000).toFixed(1)}K`;
	return tokens.toString();
}

function formatDuration(ms) {
	const totalSec = Math.floor(ms / 1000);
	const hours = Math.floor(totalSec / 3600);
	const minutes = Math.floor((totalSec % 3600) / 60);
	const seconds = totalSec % 60;

	if (hours > 0) return `${hours}h${minutes}m`;
	if (minutes > 0) return `${minutes}m${seconds}s`;
	return `${seconds}s`;
}
