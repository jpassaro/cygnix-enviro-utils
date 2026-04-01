---
name: worktree-conventions
description: Git worktree conventions - feature branches, aggregate workspaces, and multi-repo composite workflows
---

# Worktree conventions

Use these conventions when creating worktrees, setting up aggregate
workspaces, or coordinating multi-repo changes.

## Principles

- The main git directory of each repo stays on its main branch, always clean.
  Use `git pull` there to see tip.
- All feature work happens in `.worktrees/<branch-or-ticket-id>/` inside each
  repo. The `.worktrees/` directory is globally gitignored.
- When creating a worktree, base it on a fully resolved commit hash (not a
  remote ref like `origin/main`) to avoid accidentally setting up tracking:

      gitdir fetch <repo>
      hash="$(gitdir rev-parse <repo> origin/main)"   # use the repo's main branch
      git -C <repo> worktree add .worktrees/<name> -b <branch> "$hash"

## Aggregate workspaces

An aggregate workspace is a directory of symlinks to the main clone of
each repo in a related group. It provides a read-only "main at tip" view
for cross-repo search, reading, and navigation. It is not itself a git
repo or a mutable working directory.

### Setting up an aggregate workspace

    mkdir -p ~/code/my-system
    ln -s ~/code/repo-a ~/code/my-system/repo-a
    ln -s ~/code/repo-b ~/code/my-system/repo-b

Add an AI instructions file (CLAUDE.md or GEMINI.md) at the aggregate
root listing the repos, their languages, and purposes. Each repo's
main clone should stay on a clean main branch.

### Multi-repo changes

When a change spans multiple repos in an aggregate workspace:

1. In each involved repo's main directory, create a worktree:

       gitdir fetch ~/code/repo-a
       hash="$(gitdir rev-parse ~/code/repo-a origin/main)"
       git -C ~/code/repo-a worktree add .worktrees/my-feature -b my-feature "$hash"

   Repeat for each repo involved in the change.

2. Create a composite workspace with symlinks to those worktrees:

       mkdir -p ~/code/my-system/worktrees/my-feature
       ln -s ~/code/repo-a/.worktrees/my-feature \
             ~/code/my-system/worktrees/my-feature/repo-a
       ln -s ~/code/repo-b/.worktrees/my-feature \
             ~/code/my-system/worktrees/my-feature/repo-b

   Only include repos involved in the change.

3. Remove the composite directory when the PRs are merged.

## Machine-specific details

The list of repos, their main branch names, and aggregate workspace
locations are machine-specific. Check ~/.config/jp-agent/workspaces.md
for this machine's layout. Entries use the format `- ~/code/<name> (<language>,
main branch: <branch>)`. For the full format specification, see
`$JP_LOGIN_UTILS/agent/skills/worktree-conventions/workspace-reference-format.md`.
