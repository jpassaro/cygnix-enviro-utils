---
name: desk-startup
description: Use when starting a ~/desk session - processes previous day's todos, future reminders, creates today's file, and prompts for calendar/email/jira/github checks
---

# Desk Startup

Run this procedure at the start of every ~/desk session.

## Steps

### 1. Resolve today's todo file

Read ~/desk/today.md (the symlink) and check its `# YYYY-MM-DD` header.

**a) Header matches today's date** — already rolled over. Read the file
and show the current task state. Skip to step 2.

**b) Header is a past date, no `=== Journal ===` section** — a previous
session's wrapup was likely missed. Tell the user, then do a quick
wrapup of the stale file (walk through items, write a brief journal
noting the late rollover). Then treat the uncompleted items as the
carry-forward candidates for today.

**c) Header is a past date, has `=== Journal ===`** — wrapup was
completed normally. Treat uncompleted items as carry-forward candidates.

**d) today.md doesn't exist or has no header** — scan ~/desk/todo/
backwards from yesterday until a file is found (could be Friday, or
further back if the user was out). Use Glob on the current and prior
month directories — do NOT use bash for date arithmetic. Surface
uncompleted items (`[ ]`, `[~]`) as carry-forward candidates.

For cases (b), (c), and (d): ask which items should carry forward. Flag stale
items (open for more than a week) so the user can decide to act,
reschedule, or drop them. Then create ~/desk/todo/YYYYMM/DD.md with a
date header (`# YYYY-MM-DD`) and the confirmed items. Update the symlink:

    ln-today ~/desk/todo/YYYYMM/DD.md

### 2. Check future reminders

Glob ~/desk/todo/future/ for all files. Any file with a date (YYYYMMDD.md)
equal to or earlier than today is due. Surface those reminders and ask the
user to either: add to today's list, reschedule to a new future date, or
drop.

**Important: write-before-delete.** First write accepted reminders into
today's todo file. Only delete the future file after confirming the items
are present in today's file. If the session is interrupted between steps,
a duplicate reminder on next startup is preferable to a lost one.

### 3. Daily checks

Remind the user to check:
- Email
- Calendar (meetings) — if any OOO/AFK blocks, remind user to notify the
  team before moving on (see OOO protocol in the desk's AI instructions,
  e.g., ~/desk/CLAUDE.md or ~/desk/GEMINI.md)
- Open tickets and outstanding code reviews — read the desk's AI instructions
  for the specific URLs to check. If no URLs are configured there, ask the user.

### 4. Fetch and report on repos

Dispatch a **background agent** for this step so fetches don't clutter
the main session. Continue with step 5 while it runs.

The agent should:
1. **Connectivity check first.** Pick one repo and run a single
   `gitdir fetch <repo> --quiet`. If it fails (network error, timeout,
   auth failure), skip all remaining fetches and return a soft note:
   "Fetch skipped — couldn't reach remote. You may need to connect to
   VPN." This is not a showstopper; the main session continues normally.
2. Read ~/.config/jp-agent/workspaces.md for the list of repos.
3. For each repo path listed (lines matching `- ~/code/<name>`), run:

       gitdir fetch <repo> --quiet

4. Check for new upstream commits:

       gitdir log <repo> HEAD..origin/<main-branch> --oneline

5. Return a **1–2 line summary**: which repos have new commits (and
   how many each), or "all repos up to date." No tables, no commit
   lists — only expand if the user asks.

### 5. Final prompt

Ask: "Anything else to add before we start?"

## Presentation

The startup report should fit one screen. Prefer a single consolidated
view over sequential sections.

### Layout

Use vertical splits (side-by-side columns) when the terminal is wide
enough (~120+ cols):
- Left: carry-forward items. Right: future reminders.
- Left: calendar. Right: code reviews (non-draft).
- Bottom: repo summary (one line).

### Calendar formatting

- Show durations (e.g., `30m`, `75m`) after each event.
- Only show meetings the user is actually attending (ask during review).
- Render explicit free blocks between meetings:
  `~~~ free HH:MM–HH:MM ~~~`
- Flag OOO blocks that need team notification.

### ANSI formatting

Use ANSI escape codes for scannability:
- Bold (`\033[1m`) for section headers and `!!` priority markers.
- Dim (`\033[2m`) for free blocks and deferred/completed markers.

### Cross-session display

Write the report as a shell script (printf + ANSI codes) to
`.jplocal/YYYYMMDD/startup-report.sh`. This can be sent to other
sessions via `iterm say <tty> "sh <script>"`.

### Terminal size

Detect via `iterm ls -d ~/desk` to find the session TTY, then
`stty size < /dev/<tty>`. Fall back to 200x50 if detection fails.

## References

- Todo file format: see the todo-conventions skill (in the same plugin directory)

## Implementation notes

- Use Glob + Read exclusively — no bash calls needed for the scan
- Future reminder files use flat naming: ~/desk/todo/future/YYYYMMDD.md
- One reminder per line, suffixed with "(added YYYY-MM-DD)"
- Priority markers in future files (e.g., `!! item`) carry forward to tasks
