---
name: static-analysis-only
description: Constrains an agent to read-only static analysis. Use only when dispatched by a coordinator into a shared working copy alongside parallel agents. Not user-invocable.
user-invocable: false
---

# Static analysis only

## Why this constraint exists

You are working in a shared working copy that is the target of ongoing
parallel writes by other agents. A separate coordinator is responsible for
deciding when code gets edited or executed. You do not own this working copy
and must not modify it.

If you write files, run tests, install dependencies, or execute scripts, you
risk corrupting the state that other agents and the coordinator depend on.

## Hard boundaries

You MUST NOT:

- Write, create, edit, or delete any file
- Run tests, scripts, or sample code
- Install or refresh dependencies
- Execute any command that modifies the working tree or environment

These are not guidelines. Violating any of them corrupts shared state.

| Rationalization                          | Why it's wrong                                        |
| ---------------------------------------- | ----------------------------------------------------- |
| "Just one quick test to confirm"         | Coordinator owns execution. Report what you'd test.   |
| "I'll revert the file after"             | Other agents may read the file mid-edit.              |
| "I need to install X to read types"      | Read the source. Report the dependency gap.           |
| "The test is read-only, it won't change" | Tests can have side effects. You don't know.          |
| "I'll just add a print statement"        | That's a write. Say you want it; coordinator decides. |

## What you CAN do

- Read files (Read tool, Glob, Grep)
- Read git history (log, blame, diff, show)
- Web fetch and web search
- GitHub read-only API calls (gh api, gh pr view, etc.)
- Reason about code: trace data flow, follow call chains, check types,
  read tests as behavioral specs, review git blame for context

## How to do useful static analysis

- **Trace the data flow.** Follow inputs through function calls to where
  they're consumed. Most bugs live at boundaries between components.
- **Read tests as specs.** Tests document expected behavior. When the
  implementation is ambiguous, the test suite is the authority.
- **Check types and signatures.** Type annotations, function signatures,
  and return types constrain what code can do. Read them carefully.
- **Use git blame and history.** Recent changes near the problem area are
  the most likely cause. Check what changed and why (commit messages).
- **Follow error paths.** Trace what happens when things fail — missing
  error handling is a common root cause.

## Escalation

If you determine that you need to experiment to make progress — add a log
line, run a test with specific input, try a fix — say so explicitly in your
summary. Describe:

1. What you want to do and why
2. What you expect to learn from it

The coordinator will re-dispatch you in an isolated worktree where you can
work freely. This is a normal part of the workflow, not a failure. Don't be
conservative about requesting it if the static analysis hits a wall.
