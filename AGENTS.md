# AI Agent Instructions

These instructions are for AI assistants (like Gemini CLI or Claude Code)
working in this repository.

## Personal Agent Context

This repository contains a portable agent plugin in the `agent/` directory.
It follows the **Agent Skills** open standard.

### Self-Diagnostic for Agents

When starting a session in this repository, you MUST check your configuration:

1.  **Skills Check**: Run `gemini skills list` (or equivalent). Verify that
    the skills in `agent/skills/` are linked and enabled. If not, notify the
    user that they should run:
    `gemini skills link $(pwd)/agent/skills`
2.  **Instruction Check**: Verify that you have loaded the personal habits in
    `agent/AGENTS.md`. If you are not seeing instructions about "Bash habits"
    or "Communication style", notify the user.

### How to Load (for Users)

To ensure your AI assistant always has access to these portable conventions:

- **Claude Code**: Use the `jp-claude` wrapper (in `bin/`). It automatically
  adds `--plugin-dir $JP_LOGIN_UTILS/agent` to every invocation.
- **Gemini CLI**: Import the instructions in your global or workspace config:
  `echo "@agent/AGENTS.md" >> AGENTS.md`

## Architecture & Conventions

| Location                            | Scope          | Contents                                                   |
|-------------------------------------|----------------|------------------------------------------------------------|
| `login-utils/agent/`                | Portable       | AGENTS.md, skills, hooks, references                       |
| `~/.agents/AGENTS.md`               | Machine-local  | Wires up which skills to activate on session start         |
| `~/.agents/settings.json`           | Machine-local  | Hooks, env vars, permissions, enabled plugins              |
| `~/.agents/reference/`              | Machine-local  | known-workspaces.md, other machine-specific references     |
| `~/.agents/skills/`                 | Machine-local  | Work-specific skills (employer tools, internal APIs, etc.) |
| `~/desk/AGENTS.md`                  | Machine-local  | Work-specific daily context (URLs, team protocols)         |

### Work computer extras

Beyond the portable baseline, a work machine typically needs:

- `~/.agents/settings.json` — env vars for authentication (e.g. Bedrock
  profile), hooks pointing to login-utils scripts, tool permissions
- `~/.agents/reference/known-workspaces.md` — list of repos and aggregate
  workspace locations on this machine
- `~/.agents/skills/` — employer-specific skills
- `~/desk/AGENTS.md` — daily-check URLs (ticket tracker, code review),
  OOO protocol, backup destination
- `export JP_CLAUDE_CMD=<path>` in `~/.bash_profile` if using a managed
  launcher (e.g. `ca`) as the underlying claude binary
