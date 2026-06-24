# Cursor Harness

This directory is the user-level Cursor configuration source managed by this
repository.

- `agents/`: Cursor-native subagents. Cursor also supports `.claude/agents` and
  `.codex/agents`, but this directory takes precedence.
- `mcp.json`: Cursor MCP servers. Secrets must use environment interpolation.
- `cli-config.json`: Global Cursor CLI settings and permissions.
- `skills/`: Documentation only; `bin/install.sh` links `~/.cursor/skills` to
  `home/.agents/skills`.

Claude Code and Codex remain supported through their own directories.
