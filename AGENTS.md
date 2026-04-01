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

### Maintenance Check

Check [TODO.md](TODO.md) for open enhancements and design notes.

When starting a session in this repository, scan for maintenance drift
per [MAINTENANCE.md](MAINTENANCE.md). Key checks:

-   `installables` — missing or stale symlinks in `~/bin/`
-   `brew-check` — Homebrew formula drift against the brewfile
-   Uncommitted changes in this repo
-   Rogue additions to `~/.bashrc` or `~/.bash_profile` (installer-added
    PATH entries, completion sourcing, init hooks)
-   `~/.gitconfig` settings that look like they belong in the repo's
    `git-config` (shared aliases, tool preferences, etc.)

## Architecture & Conventions

See [INSTALL.md](INSTALL.md) for instructions on how to load these skills and
configure hooks (like timestamps).

| Description            | Claude Location                      | Gemini Location                      | Scope         | Contents                                                   |
|:-----------------------|:-------------------------------------|:-------------------------------------|:--------------|:-----------------------------------------------------------|
| **Portable Plugin**    | `$JP_LOGIN_UTILS/agent/`             | `$JP_LOGIN_UTILS/agent/`             | Portable      | Agnostic skills, hooks, and communication style            |
| **Workspace Registry** | `~/.config/jp-agent/workspaces.md`   | `~/.config/jp-agent/workspaces.md`   | Machine-local | List of tracked repos and aggregate workspaces             |
| **Global Settings**    | `~/.claude/settings.json`            | `~/.gemini/settings.json`            | Machine-local | Hooks, permissions, and plugin registrations               |
| **Machine Context**    | `~/.claude/CLAUDE.md`                | `~/.gemini/AGENTS.md`                | Machine-local | Wires up machine-local skills and instructions             |
| **Desk Context**       | `~/desk/CLAUDE.md`                   | `~/desk/GEMINI.md`                   | Machine-local | Daily URLs, team protocols, and OOO settings               |
| **Specialized Skills** | `~/.claude/skills/`                  | `~/.gemini/skills/`                  | Machine-local | Context-specific tools, internal APIs, or private automation |

