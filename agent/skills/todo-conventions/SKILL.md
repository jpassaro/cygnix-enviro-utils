---
name: todo-conventions
description: Todo file format, priority markers, task lifecycle, and staleness rules for ~/desk todo tracking
---

# Todo file conventions

Use these conventions when creating, editing, or reviewing todo files.

## File layout

Files live at ~/desk/todo/YYYYMM/DD.md (e.g., ~/desk/todo/202602/26.md).
~/desk/today.md is a symlink to the current day's file.

Each file starts with a date header: `# YYYY-MM-DD (Day)` (e.g.,
`# 2026-03-13 (Thu)`). Include the abbreviated day-of-week in parens.
This makes the date and day visible when reading via the symlink.

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


## Time estimates

Add a time estimate in parens before the `(added ...)` suffix when the
scope is known:

```
- [ ] :: Write epic for Schema-drift Automation (~30m) (added 2026-07-10)
- [ ] !! QA release validation for 2.73.0 (~1h) (added 2026-07-10)
```

Estimates help prioritize during startup and flag when a day is overloaded.
Use `~Xm` or `~Xh` — round to the nearest 15m for items under 2h.

When adding or carrying forward items, proactively estimate if the scope
is clear (e.g. "write an epic" → ~30m, "weekly calendar cleanup" → ~15m).
Ask the user only when scope is genuinely ambiguous (e.g. a spike with
unknown depth).

## Sections

After the task list, two optional sections:

- `=== Notes ===` — schedule, logistics, mid-session adjustments (not tasks)
- `=== Journal ===` — retrospective written at wrap-up

## Future reminders

Written directly into the target day's file: ~/desk/todo/YYYYMM/DD.md
(create the file if it doesn't exist yet). Suffix with `(added YYYY-MM-DD)`
so the user can consult that day's journal for context. When the day
arrives and the file becomes today's list, pre-seeded items are surfaced
during startup.

## Staleness

Items open for more than a week are considered stale and should be flagged
during startup and wrap-up so the user can act, reschedule, or drop them.
