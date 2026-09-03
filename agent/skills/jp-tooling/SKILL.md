---
name: jp-tooling
description: Detailed usage for gitdir, ghe, jplocal, jq, and grep patterns that avoid permission prompts. Load when operating on other repos, doing GHE operations, or dispatching subagents.
---

## gitdir

NEVER use `git -C`. No exceptions. You know your CWD from the system
prompt — use bare `git <subcommand>` for the session's own repo. For ANY
operation on another directory (read or write), use
`gitdir <subcommand> <directory> [args...]`. Colon-separated subcommands
expand to space-separated git words with no depth limit:
`gitdir worktree:list <dir>`, `gitdir remote:show <dir> origin`,
`gitdir config:get <dir> hub.host`, etc.
The colon syntax is for chaining git noun/verb subcommands — never embed
flags (e.g. `config:--get` is wrong; `config:get` is correct).
The `gitdir` permissions allowlist covers read-only commands (log, diff,
status, config:get, etc.) so they don't trigger permission prompts. Write
operations through `gitdir` still require approval as normal.
If `gitdir` is not on PATH, ask the user's permission to run
`installables install gitdir` (see login-utils MAINTENANCE.md if needed).

## ghe

For GitHub Enterprise operations, use `ghe` instead of `gh`. It exposes
only read-only commands and avoids the `GH_HOST=...` complication that
confuses permissions checks. Syntax: `ghe <command> <host/org/repo>`.
Example: `ghe pr-list github.bamtech.co/ge-accounting/datos-aggregator`.
Run `ghe --help` for available commands.
If `ghe` is not on PATH, run `installables install ghe`.

## jplocal (detailed usage)

Write files to `./.jplocal/YYYYMMDD/` in the current repo. To write a
file atomically from stdin:
`jplocal <filename> <<'EOF'` (content on stdin, closes with `EOF`).
The script creates the dated directory if needed. By default `jplocal`
refuses to overwrite existing files — pass `-f` (or `--force`) to allow
overwrite, or use the Edit tool directly on the resolved path for
appends/updates.

For long-running commands, use `jplocal --tee -f <descriptive>.log | tail`
to preserve full output while showing progress.

## Subagent passthrough

When dispatching subagents, include the following rules in the prompt.
Subagents inherit the same permission allowlists and hit the same
prompts. The tools below (`jplocal`, `jq`, `gitdir`, `ghe`) are on PATH
and auto-allowed; their alternatives trigger permission prompts.

> For temp files, use `jplocal <filename> <<'EOF'` — not `/tmp/`.
> For JSON, use `jq` — not `python3 -c`.
> For git in other repos, use `gitdir <cmd> <dir>` — not `git -C`.
> For GitHub Enterprise, use `ghe <cmd> <host/org/repo>` — not `gh`.
> For file search, use `grep -r --include='*.ext'` — not `find -exec`.
> Always quote variables: `"$var"`, `"$(cmd)"`, `"${arr[@]}"`.
> All of the above avoid permission prompts.
