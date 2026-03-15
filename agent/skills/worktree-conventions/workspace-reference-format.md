# Workspaces reference file format

This documents the expected structure of ~/desk/reference/workspaces.md.

## Purpose

Lists all workspaces on this machine, distinguishing between untracked
directories, standalone git clones, and aggregate directories (groups of
related repos). Used by desk-startup (to fetch and report updates) and
desk-wrapup (to scan for unpushed/uncommitted work).

## Expected structure

### Aggregate directories

List directories that contain symlinks to git repos. One per line:

    ## Aggregate directories (contain symlinks to git repos)

    - ~/code/datos — see its CLAUDE.md for full worktree conventions
    - ~/code/my-workspace

### Git repos grouped by aggregate

For each aggregate directory, list its repos with language and main branch:

    ## Git repos in datos

    - ~/code/datos-aggregator (Scala/SBT, main branch: main)
    - ~/code/my-lib (Python, main branch: main)

### Standalone repos

Repos not part of any aggregate:

    ## Other repos

    - ~/code/login-utils (personal dotfiles/config)
    - ~/code/side-project (Rust, main branch: main)

## Parsing expectations

Skills extract repo paths by matching lines of the form `- ~/code/<name>`
(with optional parenthetical metadata). The main branch name is parsed
from `main branch: <name>` in the parenthetical. Keep entries in this
format so skills can find them.
