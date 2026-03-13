---
name: todo-conventions
description: Todo file format, priority markers, task lifecycle, and staleness rules for ~/desk todo tracking
---

# Todo file conventions

Use these conventions when creating, editing, or reviewing todo files.

## File layout

Files live at ~/desk/todo/YYYYMM/DD.md (e.g., ~/desk/todo/202602/26.md).
~/desk/today.md is a symlink to the current day's file.

Each file starts with a date header: `# YYYY-MM-DD` (e.g., `# 2026-03-13`).
This makes the date visible when reading via the symlink.

## Task markers

- `[ ]` uncompleted
- `[~]` in progress
- `[x]` completed
- `[>]` migrated forward

## Priority markers

Appear between the checkbox and the item text:

- `!!` — top priority (must get done today)
- `::` — important (should get done today)
- (no marker) — lower priority / if time permits

Each item ends with `(added YYYY-MM-DD)`.

## Sections

After the task list, two optional sections:

- `=== Notes ===` — schedule, logistics, mid-session adjustments (not tasks)
- `=== Journal ===` — retrospective written at wrap-up

## Future reminders

Stored at ~/desk/todo/future/YYYYMMDD.md (one file per date).
One reminder per line, suffixed with "(added YYYY-MM-DD)".
Priority markers (e.g., `!! item`) carry forward when migrated to tasks.

## Staleness

Items open for more than a week are considered stale and should be flagged
during startup and wrap-up so the user can act, reschedule, or drop them.
