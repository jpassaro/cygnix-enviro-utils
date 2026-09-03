---
name: local-notes-and-checkpoints
description: Conventions for saving local notes, detailed checkpoints, and resuming work across sessions.
---

# Local Notes and Checkpoints

## Local notes — `./CLAUDE.local.md`

Officially-documented Claude Code convention (not a custom trick) —
loaded alongside `CLAUDE.md` in the directory-tree walk, read last at
each level. Works the same whether or not the directory is a git repo;
add it to `.gitignore` when it is one.

Use for: worktree/directory purpose, in-flight state, decisions, local
env quirks. Keep this file **low-token and high-level** — a broad,
dated summary of work history, not the full detail. For anything
substantial, write a detailed checkpoint (below) and link to it from
here by date instead of growing this file unbounded — a future session
can judge from the date alone whether it's worth reading further, rather
than being forced to load the full detail every time.

Trigger phrases: **"local note"**, **"note that locally"**, **"save to
local context"** → write/append to `./CLAUDE.local.md` in the relevant
directory root. Write tool creates the file if needed.

## Detailed checkpoints — `~/desk/checkpoints/YYYYMMDD/<slug>.md`

For substantial in-progress work worth a full writeup (not just the 2-4
line summary `CLAUDE.local.md` holds). Centralized globally, not
per-directory — this is what makes checkpoints auditable and recallable
across every workspace at once, and lets a single checkpoint cover
multiple workspaces when the work actually spans them. Date format
matches `~/desk/log/YYYYMMDD` for consistency.

Every checkpoint file opens with a `Workspace(s):` line naming the full
path of every directory/repo it pertains to (can be plural) — required
because the file no longer lives inside any one of them.

**Always `desk-log` immediately after writing one, including the full
checkpoint path** — e.g. `desk-log "checkpoint:
~/desk/checkpoints/20260819/missing-records-investigation.md"`. This is
what makes the checkpoint discoverable later without already knowing
which day/topic to look under.

When resuming a checkpoint via claude-term, give it an initial prompt
of the form `pick up the task in @<checkpoint-path>` so the new session
loads it immediately instead of starting cold. `claude-term`'s usage is
`[directory] [-- CLAUDE_ARGS...]` — the `--` is required, or the prompt
is parsed as a `claude-term` flag/arg and rejected:
`claude-term <dir> -- "pick up the task in @<checkpoint-path>"`.

Link to relevant checkpoints from `./CLAUDE.local.md` by date rather than
inlining the detail there.

## Legacy: `.jplocal/CLAUDE.md`, `CLAUDE.jp-notes.md`

Neither is auto-loaded the way `./CLAUDE.local.md` is (`.jplocal/CLAUDE.md`
only worked because Claude Code's directory walk happens to pick up any
file literally named `CLAUDE.md`, not because `.jplocal/` is special —
`CLAUDE.jp-notes.md` was never auto-loaded at all and needs an explicit
read, "pick up where I left off"). Prefer `./CLAUDE.local.md` for new
usage; migrate a directory's old `.jplocal/CLAUDE.md` to `CLAUDE.local.md`
next time you touch it, no need to do so proactively.

Note: the `jplocal` *shell tool* (permission-friendly temp-file writing,
see AGENTS.md "Permissions & temp files") is unrelated to this and stays
exactly as-is — this section is only about the `CLAUDE.md`-adjacent
naming convention.
