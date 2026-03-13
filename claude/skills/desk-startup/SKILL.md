---
name: desk-startup
description: Use when starting a ~/desk session - processes previous day's todos, future reminders, creates today's file, and prompts for calendar/email/jira/github checks
---

# Desk Startup

Run this procedure at the start of every ~/desk session.

## Steps

### 1. Find the most recent todo file

Scan ~/desk/todo/ backwards from yesterday until a file is found (could be
Friday, or further back if the user was out). Use Glob on the current and
prior month directories — do NOT use bash for date arithmetic.

Surface any uncompleted items (`[ ]`, `[~]`) and ask which should carry
forward to today. Flag stale items (open for more than a week) so the user
can decide to act, reschedule, or drop them.

### 2. Check future reminders

Glob ~/desk/todo/future/ for all files. Any file with a date (YYYYMMDD.md)
equal to or earlier than today is due. Surface those reminders and ask the
user to either: add to today's list, reschedule to a new future date, or
drop. Delete each future file once all its reminders are dispatched.

### 3. Create today's todo file

Create ~/desk/todo/YYYYMM/DD.md if it doesn't exist. Start the file with
a date header (`# YYYY-MM-DD`), then migrate the confirmed items from
steps 1 and 2. Then update the symlink:

    ln -sfv ~/desk/todo/YYYYMM/DD.md ~/desk/today.md

### 4. Daily checks

Remind the user to check:
- Email
- Calendar (meetings) — if any OOO/AFK blocks, remind user to notify the
  team before moving on (see OOO protocol in ~/desk/CLAUDE.md)
- Open tickets and outstanding code reviews — read ~/desk/CLAUDE.md for
  the specific URLs to check. If no URLs are configured there, ask the user.

### 5. Final prompt

Ask: "Anything else to add before we start?"

## References

- Todo file format: see reference/todo-format.md (in the same plugin directory)

## Implementation notes

- Use Glob + Read exclusively — no bash calls needed for the scan
- Future reminder files use flat naming: ~/desk/todo/future/YYYYMMDD.md
- One reminder per line, suffixed with "(added YYYY-MM-DD)"
- Priority markers in future files (e.g., `!! item`) carry forward to tasks
