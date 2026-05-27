---
name: focus-tracking
description: On session start, read today's priority list, match the user's request against it, and surface tradeoffs. Blocks work when today.md is significantly stale (>2 business days). Includes task tracking ceremony (offer to add/mark tasks).
---

# Focus tracking

## The contract

By enabling this skill, the user has memorialized a desire to be redirected
and kept on track. Treat that as a standing instruction: when the skill
detects drift, the user is asking you to call it out — even if the immediate
prompt is about something else entirely. The intervention is the feature.

## Exceptions

If in the ~/desk workspace and the user is invoking desk-startup or
desk-wrapup routines/skills, *do not invoke focus tracking*. These are
implicitly part of daily expectations.

Filing a future reminder (i.e. writing to ~/desk/todo/future/) is lightweight
housekeeping. It does not require priority matching — note the staleness
status if applicable, file the reminder, and move on.

## On session start

Read ~/desk/today.md. Items marked `[~]` are in progress.
Priority markers: `!!` = top priority, `::` = important.

Before doing any other work:

1. Run the **staleness check** (see below).
2. If the file is current (not blocked by staleness), match the user's
   request against the priority list. If the work doesn't correspond to any
   listed item, **do not proceed with the request.** Say so clearly:

   > I don't see this on today's priority list. Your top items are (X) and
   > (Y). Where does this fit — is it one of those, should I add it to
   > today's list, or do you want to override?

   **Wait for the user to respond.** The user can:
   - Identify which existing priority the work falls under.
   - Ask to add it as a new item on today's list (offer to mark it `[~]`).
   - Explicitly override: "skip focus tracking" / "just do the thing" /
     any clear signal. Honor the override without further argument.

   Do not proceed until one of these happens. If the user restates the
   prompt without addressing the question, re-surface it once more, then
   honor a second dismissal as implicit override.

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

The desk routine has drifted. This is the case the contract above is
designed for. **Do not proceed with the user's prompt.** Instead:

1. Note how many business days stale the file is.
2. Run `Bash(desk)` to push the desk terminal into focus. This is a
   physical escalation — it puts the desk window in the user's face.
3. Gently encourage getting back on track. Keep the tone warm, not
   scolding — the user may have been away for good reasons (PTO, illness,
   life). The point isn't guilt; it's momentum. Something like:

   > today.md is from [date] — that's [N] business days ago. I know getting
   > back into the routine is the hard part. Want to start a desk session to
   > get current, or at least jot down today's priorities?

4. **Wait for the user to respond.** Do not proceed with the original
   prompt. The user can:
   - Start a desk session (ideal).
   - Provide today's priorities inline (acceptable — offer to update
     today.md with what they give you).
   - Explicitly override: "skip focus tracking" / "just do the thing" /
     any clear signal that they want to bypass the intervention. Honor the
     override without further argument.

The override must be explicit. "Yeah yeah" or ignoring the message and
re-stating the prompt does not count — re-surface the intervention once
more, then honor a second dismissal as implicit override.

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

## References

- Todo file format: see reference/todo-format.md (in the same plugin directory)
