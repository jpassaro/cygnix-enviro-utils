---
name: parallel-agents
description: Dispatch 2+ agents for independent tasks with worktree isolation and coordinator rebase/integration. Replaces superpowers:dispatching-parallel-agents.
---

# Parallel agents

Dispatch independent tasks to agents working in isolation. Integrate their
changes back by rebasing onto the coordinator's branch, narrating each step.

## When to use

Use when you have 2+ tasks that:

- Concern independent problem domains
- Can each be understood without context from the others

"Independent" is a judgment call, not a file-level rule. Two agents
touching the same file does not automatically make them dependent.
Overlap in config files, constants, utils, or documentation is usually
fine — those merge cleanly. Docs-only commits can freely overlap files
with implementation commits.

The real concerns are:

- **Overlapping lines.** Two agents editing the same function body, the
  same config block, or the same test case will produce merge conflicts
  that are expensive to resolve. Prefer sequential execution for that pair.
- **Tight coupling.** Two agents changing different parts of a tightly
  coupled system — e.g., one changes a function signature while another
  changes callers of that function, or one modifies validation logic while
  another changes the data it validates — will likely produce spurious
  test failures when merged independently, even if the code merges
  without conflict. If the changes would break each other's tests when
  integrated in either order, they're not independent.

Examples: fixing unrelated test files, implementing independent features from
a plan, investigating separate bugs in different subsystems.

## When NOT to use

- Failures might be related (fix one, fix others) — investigate together first
- Tasks have overlapping lines or tight coupling (sequential is safer)
- You don't yet understand the problem (explore first, then parallelize)

## Dispatch modes

### Read-only (default for investigation/debugging)

Agents work in the current working copy with no writes or execution.
Invoke the `jp-login-utils:static-analysis-only` skill in the agent prompt:

```
Agent({
  description: "Investigate auth timeout",
  prompt: "Use the jp-login-utils:static-analysis-only skill. [task details...]"
})
```

No worktree overhead. Agents can read files, grep, read git history, web
fetch, web search, and call read-only GitHub APIs.

If an agent reports that it needs to experiment (add logs, run tests, try a
fix), re-dispatch it in full-isolation mode using its findings as context.

### Full isolation (default for implementation)

Each agent gets its own git worktree and commits there:

```
Agent({
  description: "Implement retry logic",
  prompt: "[task details...]",
  isolation: "worktree"
})
```

Include this preamble in every full-isolation agent prompt:

> You are in an isolated git worktree. Other agents are working in parallel
> on separate worktrees. Commit each logical change separately so the
> coordinator can integrate selectively. In your summary, list each commit
> with a one-line description of what it does and why.
>
> Before returning, run the acceptance command and verify all checks pass.
> Include the full output in your response. Note any expected failures
> (xfails) explicitly. Report the HEAD sha of your final commit.

## Acceptance command

Before dispatching agents, determine the project's acceptance command —
the checks that must pass for a commit to be acceptable. Check the spec
or implementation plan first — it may specify the command directly.
Otherwise, discover it the same way a new engineer would: read project
docs (README, CLAUDE.md, CONTRIBUTING, Makefile, CI config, package.json
scripts). Typical examples:
`make check-all`, `npm run lint && npm run typecheck && npm test`, etc.

Pass the acceptance command to every agent and use it in the integration
phase. Cache it for the session.

When documentation is in scope, the acceptance command should also include
reviewing changed doc files for coherence. During integration, the
coordinator should review the union of doc files changed by both sides.
Concretely: diff the agent's branch against the coordinator's HEAD in both
directions (`git diff --name-only HEAD...<agent-branch>` and
`git diff --name-only <agent-branch>...HEAD`) and review any doc files
that appear in either diff for consistency with each other.

## Writing agent prompts

Each agent gets a self-contained prompt. It has no access to your session
history or other agents' work.

Every prompt must include:

1. **Specific scope** — one task, one problem domain
2. **Sufficient context** — everything the agent needs to understand the
   problem. Include file paths, error messages, relevant plan sections.
   Don't make it guess or explore broadly.
3. **Constraints** — what it should NOT touch (other subsystems, unrelated
   files)
4. **Expected output** — what the summary should contain (root cause,
   changes made, commits, open questions)

Bad: "Fix the tests."
Good: "Fix the 3 failing tests in src/auth/test_timeout.py. The failures
started after commit abc123 which changed the retry logic. Read the test
file and the retry module, identify root cause, fix, and commit. Don't
change anything outside src/auth/. Return: root cause, what you changed,
commit hashes."

## Integration phase

When agents return, integrate their changes onto the coordinator's branch.
Narrate every step to the human.

### Ordering

Default: first-come-first-served (order agents completed).

Override when context suggests a better order — e.g., the spec or plan
implies a dependency, one agent's changes are foundational to another's,
or the nature of the changes makes a particular sequence cleaner. Use all
available context (spec, plan, agent summaries, what the changes touch).
Don't wait for the human to specify order unless it's genuinely ambiguous.

### Step 1: Try fast-forward

For each agent (in chosen order), try `git merge --ff-only <agent-branch>`.

If the fast-forward succeeds and the agent verified that the acceptance
command passed, accept unconditionally. Report: "Integrated [agent
description] via fast-forward — [N] commits. Agent verified acceptance
passed."

If fast-forward fails (branches have diverged), fall through to Step 2.

### Step 2: Rebase with acceptance checks

Rebase the agent's branch onto the coordinator's current HEAD, running the
acceptance command after each replayed commit:

```
git -C "$agent_worktree" rebase -x "$acceptance_command" "$coordinator_head"
```

Narrate the progress:

- **Starting:** "Rebasing [agent description] — N commits onto [sha]."
- **Each commit:** "Replayed [hash] — [one-line description]. Acceptance
  [passed/failed]."

**If the rebase succeeds** (all commits replayed, all acceptance checks
pass): fast-forward the coordinator's branch to the rebased result.

**If a commit fails acceptance or has merge conflicts:** the coordinator
must decide whether to back out or leave the broken state for the agent.

- `rebase --abort` restores the agent's branch to its original delivered
  state. Appropriate when the agent would just hit the same problem again
  (e.g., a semantic conflict it can't resolve without understanding the
  other agent's work).
- Leaving the broken state (conflicted rebase or failed acceptance after
  successful replay) lets the agent resume where it got stuck.
  Appropriate when the agent has enough context to fix forward.

A third option: **fresh re-dispatch from scratch.** If the agent's task
is small or mechanical enough that redoing it on the current baseline is
cheaper than explaining the broken state, just `rebase --abort`, discard
the worktree, and re-dispatch from the original prompt (updated with the
current coordinator HEAD as the starting point). This is often the right
call when the conflict is extensive relative to the agent's total work.

This is a judgment call. When re-dispatching into a broken state, provide:

- The original delivered sha (from the agent's initial summary)
- Whether the worktree is in a broken rebase, post-rebase with failed
  acceptance, or cleanly aborted
- What changed on the coordinator's branch since the agent started
- The acceptance failure or conflict details

**Lint-only failures** after a successful replay are the one exception:
the coordinator should fix and amend directly, then continue the rebase
without re-dispatching.

### Conflict resolution

**Coordinator resolves** when the conflict is mechanical — two agents added
imports in the same spot, touched adjacent lines with no semantic overlap,
or made independent additions to the same file. Resolve, narrate what you
did, and continue the rebase.

**Re-dispatch** when the conflict is substantive but resolvable — the
agent's approach is still valid but needs to be redone against the current
integrated state. `rebase --abort` to restore the agent's original branch,
then re-dispatch with the current state as the new baseline and the
original task plus context about what changed.

**Escalate to human** when there's a true semantic conflict — two agents
made contradictory design choices, or the right resolution requires a
judgment call about product intent. `rebase --abort`, stop integration,
explain the conflict, present options.

### Completion

After all agents' changes are integrated:

1. Summarize what was integrated: list each agent, its commits, and any
   conflicts resolved.
2. Run a final acceptance pass on the integrated result.
3. Clean up agent worktrees (`git worktree remove <path>`) for
   successfully integrated agents. Leave worktrees intact for agents
   whose work was not fully integrated (pending re-dispatch, escalated
   conflicts) — the human or a future agent may need them.
4. Report the final state.

## Common mistakes

- **Ignoring tight coupling** — sharing a file is fine, but overlapping
  lines or tightly coupled changes will cause merge conflicts or test
  failures. Combine those into one agent or run them sequentially.
- **Prompts that assume session context** — agents start cold. Include
  everything they need.
- **Skipping verification between agents** — a failure during agent 2's
  rebase may be caused by agent 1's changes breaking something. Catch it
  early.
- **Over-parallelizing** — three agents is usually the sweet spot. More
  than that and integration overhead dominates. Use judgment.
