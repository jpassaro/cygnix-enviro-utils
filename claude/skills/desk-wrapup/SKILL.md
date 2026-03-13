---
name: desk-wrapup
description: Use when wrapping up a ~/desk session or ending the day - reviews tasks, writes journal, surfaces pending reminders
---

# Desk Wrap-up

Run this procedure when the user says they're done or wrapping up.

## Steps

### 1. Review today's todo file

Read ~/desk/today.md. Walk through each item with the user:
- Mark completed items `[x]`
- Mark items to migrate forward `[>]`
- Note items still in progress `[~]`

### 2. Check wrap-up reminders

Review the `=== Notes ===` section for any items tagged as wrap-up
reminders. Surface these explicitly — do not let the user leave without
addressing them.

### 3. Interview feedback check

If the user's schedule included an interview today, do not let them leave
without having written feedback. Submission can wait a day, but writing
cannot.

### 4. Write journal entry

Add a `=== Journal ===` section to today's file. Brief retrospective:
- What got done
- What didn't and why
- Any lessons, observations, or retrospective notes worth carrying forward

### 5. Tomorrow prep

Ask if any open items need notes for tomorrow. Offer to:
- Create future reminder files for deferred items
- Add notes to tomorrow's file if it exists
- Flag anything that needs attention first thing

### 6. Unpushed work check

Scan all worktrees for uncommitted or unpushed work:

```bash
for wt in ~/code/*/.worktrees/*/; do
    if [ -d "$wt/.git" ] || [ -f "$wt/.git" ]; then
        unpushed="$(cd "$wt" && git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')"
        dirty="$(cd "$wt" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
        if [ "$unpushed" != "0" ] || [ "$dirty" != "0" ]; then
            printf "%s  (unpushed: %s, dirty: %s)\n" "$wt" "$unpushed" "$dirty"
        fi
    fi
done
```

Do not let the user leave with unpushed commits. Dirty files should at
minimum be committed (WIP is fine). Unpushed branches must be pushed.

### 7. Final state

Show the user the final task summary: completed count, open count, migrated
count. Surface any stale items (open for more than a week) one more time.
