---
name: focus-tracking
description: On session start, read today's priority list, match the user's request against it, and gently surface adherence. Never blocks — always proceeds after calling out drift. Includes task tracking ceremony (offer to add/mark tasks).
---

# Focus tracking

## The contract

By enabling this skill, the user has memorialized a desire to have agenda
adherence surfaced. When the skill detects drift, call it out gently — but
**never block**. The callout is the feature; the user decides whether to
act on it. Always proceed with the user's request after noting the drift.

## Exceptions

If in the ~/desk workspace and the user is invoking desk-startup or
desk-wrapup routines/skills, *do not invoke focus tracking*. These are
implicitly part of daily expectations.

Filing a future reminder (i.e. writing to ~/desk/todo/YYYYMM/DD.md for a
future date) is lightweight housekeeping. It does not require priority
matching — note the staleness status if applicable, file the reminder, and
move on.

## On session start

Read ~/desk/today.md. Items marked `[~]` are in progress.
Priority markers: `!!` = top priority, `::` = important.

Before doing any other work:

1. Run the **staleness check** (see below).
2. If the file is current (not blocked by staleness), match the user's
   request against the priority list. If the work doesn't correspond to any
   listed item, note it gently before proceeding:

   > I don't see this on today's priority list. Your top items are (X) and
   > (Y) — noting for awareness.

   Then proceed with the user's request. Do not wait or block.

## Staleness check

Note the date in today.md's `# YYYY-MM-DD` header. Compare it to the
current date (from the injected timestamp). Compute business days elapsed
(exclude weekends; don't try to account for holidays).

### Fresh (0 business days)

No staleness concern. Proceed to priority matching.

### Slightly stale (1–2 business days)

Flag it lightly:

> today.md is from [date] — you may want to roll it over when you get a
> chance.

Proceed to priority matching and the user's request. Don't block.

### Significantly stale (>2 business days)

The desk routine has drifted. Note it warmly before proceeding:

1. Note how many business days stale the file is.
2. Gently encourage getting back on track. Keep the tone warm, not
   scolding — the user may have been away for good reasons (PTO, illness,
   life). The point isn't guilt; it's momentum. Something like:

   > today.md is from [date] — that's [N] business days ago. When you get
   > a moment, a quick desk session would help get current.

3. **Proceed with the user's request.** Do not block or wait.

### Mid-session staleness

If a later user message's timestamp shows a different (later) day than the
today.md header, re-read today.md — the file may have been rolled over by
another session. If the header still shows the old date and there's no
`=== Journal ===` section, apply the staleness tiers above based on the
new elapsed time. Don't attempt the rollover in-place from a non-desk
workspace — it's interactive and would clutter the current session's
context.

## Task tracking ceremony

- If the user indicates a new task, offer to add it to the to-do list.
- For a new task or one that is not in progress, offer to mark it `[~]`.
- When done, offer to mark the task complete `[x]`.

## Telemetry

Always log the session start after the focus check, regardless of
staleness or drift:

    desk-log "started session for <goal/tag>, timebox <N>m"

If focus tracking was skipped (exception), log that instead:

    desk-log "skipped focus check: <reason>, timebox 10m"

## References

- Todo file format: see reference/todo-format.md (in the same plugin directory)
