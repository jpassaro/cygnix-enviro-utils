# Worktree conventions

## Principles

- The main git directory of each repo stays on its main branch, always clean.
  Use `git pull` there to see tip.
- All feature work happens in `.worktrees/<branch-or-ticket-id>/` inside each
  repo. The `.worktrees/` directory is globally gitignored.
- When creating a worktree, base it on a fully resolved commit hash (not a
  remote ref like `origin/main`) to avoid accidentally setting up tracking:

      cd <repo> && git fetch
      hash="$(git rev-parse origin/main)"   # use the repo's main branch
      git worktree add .worktrees/<name> -b <branch> "$hash"

## Aggregate workspaces

Some directories (e.g. ~/code/datos) are aggregate workspaces: a directory
of symlinks to the main clone of each repo in a group. These are read-only
"main at tip" views for cross-repo search and reading.

For multi-repo changes, create per-repo worktrees and then a composite
workspace with symlinks:

    mkdir -p <aggregate>/worktrees/<feature>
    ln -s <repo-A>/.worktrees/<feature> <aggregate>/worktrees/<feature>/<repo-A>
    ln -s <repo-B>/.worktrees/<feature> <aggregate>/worktrees/<feature>/<repo-B>

Remove the composite directory when the PRs are merged.

## Machine-specific details

The list of repos, their main branch names, and aggregate workspace
locations are machine-specific. Check ~/.claude/reference/known-workspaces.md
(if it exists) for this machine's layout.
