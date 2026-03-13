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

Read ~/.claude/reference/known-workspaces.md to get the list of tracked
repos. For each repo path listed, scan for worktrees at <repo>/.worktrees/*/
and check the repo root itself. For each git directory found, check for
uncommitted or unpushed work:

```bash
# For each directory (repo root or worktree):
unpushed="$(cd "$dir" && git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')"
dirty="$(cd "$dir" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
```

Report any directories with unpushed > 0 or dirty > 0.

Do not let the user leave with unpushed commits. Dirty files should at
minimum be committed (WIP is fine). Unpushed branches must be pushed.

If ~/.claude/reference/known-workspaces.md is missing, fall back to
scanning ~/code/*/.worktrees/*/ directly and warn the user that the
reference file should be created.

### 7. Backup local state

Run the backup-local-state.sh script (in the hooks/ directory of this plugin)
to archive ~/.claude and ~/desk. The backup destination is machine-specific —
check ~/desk/CLAUDE.md or ~/.claude/CLAUDE.md for the configured path.

If no destination is configured, remind the user to set one up and skip the
backup step.

### 8. Final state

Show the user the final task summary: completed count, open count, migrated
count. Surface any stale items (open for more than a week) one more time.
