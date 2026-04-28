# Codex Skill Compatibility

This directory is the Codex-specific copy of the shared custom skills.

## Runtime Mapping

- Treat `allowed-tools` entries copied from Claude Code as documentation only. Use the actual Codex tools available in the current session.
- `AskUserQuestion`: in Plan mode, use `request_user_input` for material choices; in Default mode, ask a concise plain-text question only when a safe assumption is not possible.
- `Task` / `Agent`: use `spawn_agent` only when the user explicitly asks for sub-agents, delegation, or parallel agent work. Otherwise perform the work locally.
- `Read` / `Grep` / `Glob`: inspect files with normal reads and shell commands, preferring `rg` / `rg --files`.
- `Edit` / `Write`: edit repo files with `apply_patch` unless a formatter or mechanical tool is the right operation.
- `Bash(...)`: use `shell_command`, preserve the configured sandbox and approval policy, and request escalation when required.
- `WebSearch` / `WebFetch`: use the available web tools. For current or unstable facts, browse before answering.

## Behavioral Defaults

- Do not run `git commit`, `git push`, `git merge`, or `git rebase` without explicit user confirmation.
- Do not run destructive filesystem commands without explicit user confirmation.
- Keep Claude Code-only workflow terms out of user-facing output unless explaining compatibility.
