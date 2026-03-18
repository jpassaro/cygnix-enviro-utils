---
name: focus-tracking
description: On session start, read today's priority list, match the user's request against it, and surface tradeoffs. Includes task tracking ceremony (offer to add/mark tasks).
---

# Focus tracking

## On session start

Read ~/desk/today.md. Items marked `[~]` are in progress.
Priority markers: `!!` = top priority, `::` = important.

Before doing any other work, match the user's request against the list. If
the work doesn't correspond to any listed item, say so in your first response:

> I don't see this on today's priority list. Your top items are (X) and (Y).
> Do you want to switch to one of those tasks, or continue here, or update the
> to-do list?

Then proceed with the user's request regardless of their answer. If continuing
on something that isn't a priority, don't block — just surface the tradeoff.

## Date staleness check

Note the date in today.md's `# YYYY-MM-DD` header at session start. If a
later user message's timestamp shows a different (later) day, re-read
today.md — the file may have been rolled over by another session, or the
rollover may have been missed. If the header still shows the old date and
there's no `=== Journal ===` section, flag it: "today.md looks stale —
start a desk session to roll over?" Don't attempt the rollover in-place
from a non-desk workspace — it's interactive and would clutter the
current session's context.

## Task tracking ceremony

- If the user indicates a new task, offer to add it to the to-do list.
- For a new task or one that is not in progress, offer to mark it `[~]`.
- When done, offer to mark the task complete `[x]`.

## References

- Todo file format: see reference/todo-format.md (in the same plugin directory)
