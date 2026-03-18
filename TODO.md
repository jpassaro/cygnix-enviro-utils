# TODO

## Portability extraction

- [ ] Make login-utils/claude/ loadable without --plugin-dir
      The plugin system (`claude plugins install`) only supports git-hosted
      marketplaces -- no file:// or local path source. Symlink hacks on the
      installPath in the cache would break on `claude plugins update`. Options:
        a) Host as a plugin in a personal marketplace repo on GitHub
        b) Wait for Claude Code to support local plugin sources
        c) (Current workaround) Pass --plugin-dir on every invocation
      For now, ensure all launch paths (ca, claude-term) pass --plugin-dir.
      Revisit when the plugin system gains local-source support.

- [ ] Consider splitting worktree-conventions.md into reference + skill
      The multi-repo composite workflow is procedural enough to be a
      create-worktree skill. Reference would keep just the conventions
      (where worktrees live, commit-hash rule, what aggregates are).
      Revisit when the procedure is invoked often enough to warrant it.

- [ ] Document initial desk setup
      Nothing currently describes creating ~/desk, ~/desk/todo/, the symlink,
      ~/desk/reference/workspaces.md, or the required sections in
      ~/desk/CLAUDE.md from scratch. Add a desk-setup skill or README section.
      The guide wants a "work device vs personal device" divide. Work device
      essentials: daily-check URLs, OOO protocol, backup destination,
      wrap-up/hard-out times. Personal device: TBD -- think about what the
      counterpart looks like. Decide the split, then either add a
      template or document inline in the desk-startup/desk-wrapup skills.

- [ ] Fix plugin CLAUDE.md not loading AGENTS.md content
      Claude Code ignores `contextFileName` in plugin.json and the `@AGENTS.md`
      include syntax in CLAUDE.md. The loaded context is the literal string
      `@AGENTS.md`, so none of the bash habits, tempfile conventions, etc.
      reach the agent. Fix: `ln -sf AGENTS.md CLAUDE.md` in the agent/
      directory so Claude Code picks up the real content while Gemini can
      still use `contextFileName`.

## Pre-commit-checks skill (design)

Behavioral skill for the plugin directory. Teaches the agent when and how to
verify code before committing -- using judgment, not mechanical hooks.

### Approach

Auto-detect with prose overrides:

1. **Fuzzy discovery** -- on first commit attempt or first encounter with a
   repo, read whatever project docs exist (README, CLAUDE.md, CONTRIBUTING,
   Makefile, CI config, package.json scripts) for build/lint/typecheck/test
   instructions. No prescribed section name or location.
2. **Structure fallback** -- if docs don't mention checks, detect from project
   files: tsconfig.json -> `tsc --noEmit`, go.mod -> `go vet ./...`,
   Cargo.toml -> `cargo check`, pyproject.toml w/ mypy -> `mypy`, etc.
3. **Cache for session** -- don't re-discover on every check.

### Judgment principles (when to run)

**Don't run when:**
- Mid-edit on related files (e.g., adding import + using it)
- Changes are cosmetic (comments, docs, README, formatting)
- About to edit the same file again

**Good times to run:**
- After completing a logical unit of work (finishing a checklist item)
- After touching a new file type not yet checked this session
- When switching areas of the codebase

**Rough tiering guideline:**
- Fast checks (lint, typecheck) are fine at logical boundaries
- Slow checks (full test suite) save for pre-commit

**Hard gate:** All discovered checks run before commit. Fail -> fix before
committing.

### Scope matching

Match checks to what actually changed. Only .tf files? Just terraform
validate. Only README? Skip everything. Mixed? Run the relevant subset.

### Failure mid-work

If a check fails outside of pre-commit, ask the user before going in hot
to fix it.

### Config format

Prose, wherever the repo already documents its build/check process. No new
config format, no prescribed section name. The agent reads project docs the
same way a new engineer would on day one.

### Open questions

- Exact wording of the skill instructions (SKILL.md)
- Whether to include a `/typecheck` manual trigger or keep it purely
  behavioral
- Where slow/fast tiering boundary sits for specific checkers (is `pytest`
  always slow? depends on the repo)
- The plugin directory name `claude/` causes skills to appear with a
  `claude:` prefix (e.g., `claude:desk-startup`), which reads like an
  official namespace. Rename to something personal (`jp/`, `personal/`,
  etc.) when restructuring.

## End-to-end testing

- [ ] Confirm soft-timebox and end-of-day-awareness skills work with the
      timestamp hook in a real session. The hook
      (agent/hooks/user-prompt-timestamp.sh) outputs "Current time:
      YYYY-MM-DD HH:MM" on every prompt via UserPromptSubmit. Both skills
      reference "timestamps injected by the UserPromptSubmit hook" -- verify
      they actually fire nudges/escalations at the right times.

## Shell code TODOs

- [ ] `bashrc.d/function` -- split god file into focused files
      (e.g., function-nav, function-text, function-git)
- [ ] `bashrc.d/function-rarelyused:16` -- create mac-specific conditional
- [ ] `bashrc.d/completion:66` -- condition completion loading on an envvar
      settable before sourcing in .bashrc
- [ ] `bashrc.d/prompts:10` -- test PS1 on linux
- [ ] `bin/utfdump:8` -- add options to format codepoints and counts
      (e.g., decimal or octal)
