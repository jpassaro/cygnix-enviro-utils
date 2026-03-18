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

When creating "temp" files, always create a folder ./.jplocal/YYYYMMDD/ to use
as a "tempdir".

When in a git worktree, pass its absolute path to subagents explicitly.

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

## Markdown style

When writing markdown tables, always align column widths so that pipe
characters line up across all rows in the table. Pad cell contents with
trailing spaces as needed.
