These instructions are loaded from the login-utils plugin (path provided
by the session-start hook). See its README.md if needed for detail on
installables, bin/ scripts, and other documentation.

## Communication style

When answering questions, cite the source (file path, documentation URL, or
tool output) so I can verify the answer myself.

Avoid unearned positive feedback ("great idea", "that's a great approach",
etc.) on choices that are routine, arbitrary, or aesthetic. Default to neutral
acknowledgment and just proceed with the work. Reserve genuine praise for
ideas that are actually non-obvious or clever. When you would do something
differently, say so briefly with a reason. This matters for maintaining trust
in the signal — if everything gets praised, praise means nothing.

When the user sends a terse affirmation ("y", "yeah", "sure", "go ahead"),
pick the reasonable default and keep moving. State which choice you made in
one line so they can redirect if needed. Do not block for clarification —
the user may be on a call or multitasking.

## Bash habits

The bash tools "mv", "cp", "ln", and others, should always be run with the
"-v" option so I can see what you are doing.

In bash commands, always quote variables and process substitutions: `"$var"`,
`"$(cmd)"`, `"${arr[@]}"`. No exceptions.

Shebangs in new bash scripts should use `#!/usr/bin/env bash`. Scripts that
don't need bash features should use `#!/bin/sh` and stay POSIX-compliant.

GNU coreutils, findutils, sed, tar, awk, and grep are on PATH in AI agent
sessions (like Claude Code or Gemini CLI), so GNU extension flags are
available. In scripts that need to be portable, stick to POSIX-specified
behavior and avoid GNU extensions.

For in-place sed, always use `sed -i.jp-garbage` (not `sed -i` or
`sed -i ''`). This works identically on macOS and GNU/Linux.
The `.jp-garbage` backup files are globally gitignored.

When creating "temp" files, always create a folder ./.jplocal/YYYYMMDD/ to use
as a "tempdir".

To write a file atomically to that directory from stdin, use:
`jplocal <filename> <<'EOF'` (content on stdin, closes with `EOF`).
The script creates the dated directory if needed. Useful for checkpoints,
drafted notifications, or any artifact that should survive the session
but not be committed. By default `jplocal` refuses to overwrite existing
files — pass `-f` (or `--force`) to allow overwrite, or use the Edit
tool directly on the resolved path for appends/updates.

For long-running commands (terraform apply/destroy, large builds, etc.),
don't pipe solely to `tail` — use
`jplocal --tee -f <descriptive>.log | tail` so the full output is
preserved for inspection while the command runs and after it completes.

Don't search broad parent directories (`~/code/`, `$HOME`, etc.) without
limiting depth to at most 2 or 3. Use `find -maxdepth`, `grep --depth=`,
or equivalent when searching outside the current project. If no
depth-limiting option is available, ask for the correct path instead.
User can override explicitly.

When in a git worktree, pass its absolute path to subagents explicitly.

Never `cd` to change the session's working directory. If a command needs
to run elsewhere, wrap it in a subshell: `(cd /other/path && cmd)`. If
ongoing work in another directory is needed, record context there
(CLAUDE.jp-notes.md) and open a claude-term.

## Command wrappers (permissions)

These commands exist to avoid false-positive permission prompts in
Claude Code. Use them instead of the underlying tools.

**Subagent note:** When dispatching subagents, pass this section in the
prompt. Subagents inherit the same permission allowlists. Tell them:
(1) use `gitdir` not `git -C` for other repos, (2) use `ghe` not `gh`
for GHE reads, (3) use `grep -r` not `find -exec grep`.

| Instead of                                   | Use                                          | Why                                    |
|:---------------------------------------------|:---------------------------------------------|:---------------------------------------|
| `git -C <dir> <cmd>`                        | `gitdir <cmd> <dir>`                         | Allowlisted per-subcommand             |
| `GH_HOST=... gh <cmd>`                      | `ghe <cmd> <host/org/repo>`                  | Env prefix triggers permission prompt  |
| `find <dir> -name '*.x' -exec grep ...`     | `grep -r --include='*.x' <pattern> <dir>`    | find-exec not allowlisted; grep -r is  |

### gitdir

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

### ghe

For GitHub Enterprise operations, use `ghe` instead of `gh`. It exposes
only read-only commands and avoids the `GH_HOST=...` complication that
confuses permissions checks. Syntax: `ghe <command> <host/org/repo>`.
Example: `ghe pr-list github.bamtech.co/ge-accounting/datos-aggregator`.
Run `ghe --help` for available commands.
If `ghe` is not on PATH, run `installables install ghe`.

### grep over find-exec

Prefer `grep -r --include='*.ext' <pattern> <dir>` over
`find <dir> -name '*.ext' -exec grep ... {} \;` or piping through
`xargs grep`. The `grep -r` form is allowlisted, simpler, and faster
(no process-per-file overhead).

Multiple patterns: `--include='*.scala' --include='*.sbt'`
Exclude dirs: `--exclude-dir='.git'`

## Personal local-only files

Two files provide per-repo context that is local to the user (globally
gitignored, never committed):

- `CLAUDE.jp-notes.md` — personal notes, task context, or reminders for a
  specific repo or worktree. Lives alongside CLAUDE.md at the repo root.
- `.jplocal/CLAUDE.md` — local-only project instructions (supplements the
  committed CLAUDE.md).

These files are NOT read proactively on every session start. Read them when:
- The user says "let's go", "pick up where I left off", or similar resume cues
- The user references personal notes or local context
- Starting work in a worktree (check for worktree-specific context)

When the user wants to save context to another directory (rough plans, future
tasks, reminders for a different repo), write it to CLAUDE.jp-notes.md in that
directory. Create the file if it doesn't exist; append if it does.

## Commit messages

In commit message bodies, distinct changes belong in distinct paragraphs.
Each paragraph can be multi-sentence, but should cover one logical change.
This keeps `git log` scannable when a commit touches multiple files for
related-but-separable reasons.

## End-of-day time awareness

Use injected timestamps to monitor the time of day. Escalate with increasing
directness at these thresholds (once per threshold, at the top of the response):

- **Past 17:00** — "FYI it's past 5. Should we think about wrapping up?"
- **Past 17:30** — "Hey, it's past 5:30. You may want to put this down."
- **Past 18:00** — "It's past 6, getting late. Should we stop?"
- **Past 18:30** — "6:30. Your kids are waiting. Let's call it a night."
- **Past 19:00+** — Do not continue until the user explicitly acknowledges
  the time and states why the work can't wait until tomorrow. Be blunt:
  "It's past 7. What's going on that can't wait until morning?"

Project-level instructions (CLAUDE.md, GEMINI.md) may override these
thresholds for specific contexts.

## Urgency signals and session-start ceremony

Session-start skills (focus-tracking, etc.) run before responding to the
user's first message. Imperative tone, concrete questions, and simple
lookups are NOT urgency signals — do not skip or rush ceremony because
the answer seems quick or obvious.

Skip or downgrade only when the prompt contains genuine urgency signals:

- **Active incident (skip ceremony entirely):** "prod is down", "P0",
  "outage", or similar. The staleness note would be a distraction.
- **Explicit time constraint (downgrade to one-line reminder):** "token
  expiring", "deploy window closes at X". Run the check but don't block;
  note you'll circle back.
- **Everything else (full ceremony):** The user's request waits.

## Agent env (sharing values with the user's shell)

When you discover a path, URL, branch name, commit SHA, or other value the
user might want to act on, save it with the `set_env` MCP tool. This writes
to a per-session env file that the user can load via `src()`.

After calling `set_env`, always tell the user what you saved and suggest the
`! src` pattern so they can use it immediately. Example:

> I saved the worktree path. Grab it with: `! src && cd "$WORKTREE"`

Use short, descriptive names: `WORKTREE`, `PR_URL`, `COMMIT`, `BRANCH`.
Overwriting a variable replaces the previous value (no duplicates).
Pass `null` as the value to unset.

## Markdown style

When writing markdown tables, always align column widths so that pipe
characters line up across all rows in the table. Pad cell contents with
trailing spaces as needed.
