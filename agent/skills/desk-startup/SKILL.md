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

    ln -sfv ~/desk/todo/YYYYMM/DD.md ~/desk/today.md

### 2. Check future reminders

Glob ~/desk/todo/future/ for all files. Any file with a date (YYYYMMDD.md)
equal to or earlier than today is due. Surface those reminders and ask the
user to either: add to today's list, reschedule to a new future date, or
drop. Delete each future file once all its reminders are dispatched.

### 3. Daily checks

Remind the user to check:
- Email
- Calendar (meetings) — if any OOO/AFK blocks, remind user to notify the
  team before moving on (see OOO protocol in the desk's AI instructions,
  e.g., ~/desk/CLAUDE.md or ~/desk/GEMINI.md)
- Open tickets and outstanding code reviews — read the desk's AI instructions
  for the specific URLs to check. If no URLs are configured there, ask the user.

### 4. Fetch and report on repos

Read ~/.config/jp-agent/workspaces.md for the list of repos. For each repo
path listed (lines matching `- ~/code/<name>`), run:

    git -C <repo> fetch --quiet

Then check for new upstream commits:

    git -C <repo> log HEAD..origin/<main-branch> --oneline

Report a summary: which repos have new commits, how many each. If any
repos updated, offer to summarize the new commits if the user wants.
Skip repos that aren't git directories or don't exist on this machine.

### 5. Final prompt

Ask: "Anything else to add before we start?"

## References

- Todo file format: see the todo-conventions skill (in the same plugin directory)

## Implementation notes

- Use Glob + Read exclusively — no bash calls needed for the scan
- Future reminder files use flat naming: ~/desk/todo/future/YYYYMMDD.md
- One reminder per line, suffixed with "(added YYYY-MM-DD)"
- Priority markers in future files (e.g., `!! item`) carry forward to tasks
