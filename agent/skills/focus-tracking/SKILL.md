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

## Task tracking ceremony

- If the user indicates a new task, offer to add it to the to-do list.
- For a new task or one that is not in progress, offer to mark it `[~]`.
- When done, offer to mark the task complete `[x]`.

## References

- Todo file format: see reference/todo-format.md (in the same plugin directory)
