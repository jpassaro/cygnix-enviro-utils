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

### 2. Check for pre-seeded items in today's file

Future reminders are written directly into ~/desk/todo/YYYYMM/DD.md ahead
of time. When creating today's file (step 1), any items already present in
the file are pre-seeded reminders. Surface them explicitly so the user
can confirm, reprioritize, or drop them before adding new items.

### 3. Daily checks

Remind the user to check:
- Email
- Calendar (meetings) — if any OOO/AFK blocks, remind user to notify the
  team before moving on (see OOO protocol in the desk's AI instructions,
  e.g., ~/desk/CLAUDE.md or ~/desk/GEMINI.md)
- Open tickets and outstanding code reviews — read the desk's AI instructions
  for the specific URLs to check. If no URLs are configured there, ask the user.

### 4. Final prompt

Ask: "Anything else to add before we start?"

## Presentation

The startup report should fit one screen. Prefer a single consolidated
view over sequential sections.

### Layout

Use vertical splits (side-by-side columns) when the terminal is wide
enough (~120+ cols):
- Left: carry-forward items. Right: pre-seeded reminders (if any).
- Left: calendar. Right: code reviews (non-draft).

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
- Future reminders are pre-seeded directly into ~/desk/todo/YYYYMM/DD.md
