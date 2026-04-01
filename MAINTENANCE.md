# Maintenance and Syncing

This guide explains how to keep your `login-utils` environment in sync across 
machines and ensure new improvements are captured in version control.

## Keeping the Repository Up-to-Date

Since these utilities are part of your daily workflow, you will often make 
small tweaks. To ensure these aren't lost:

### Committing Changes

1.  **Check for changes**:
    ```bash
    git status
    ```
2.  **Review your diffs**:
    ```bash
    git diff
    ```
3.  **Commit and Push**:
    ```bash
    git add .
    git commit -m "Brief description of the change"
    git push gh main  # Assuming 'gh' is your GitHub remote
    ```

## Managing Utility Scripts (`~/bin/`)

The workflow for new scripts is designed for safe iteration:

1.  **Iterate Locally**: Put new, experimental scripts in `~/bin/`.
2.  **Stable Migration**: Once a script is stable, move it into 
    `login-utils/bin/` and replace the local copy with a symlink.

### Using `installables`

The `installables` function (defined in `bashrc.d/installables`) automates
this process. It runs quietly on every shell startup.

-   **Check status**: Run `installables` to see which scripts are missing
    symlinks or are eligible for version control.
-   **Interactive Sync**: Run `installables interactive` to walk through
    each item and decide whether to install, ignore, or add it to the repo.
-   **Install one**: Run `installables install NAME` to symlink a single
    script from `bin/` into `~/bin`.
-   **Ignore one**: Run `installables ignore NAME` to permanently skip
    installing a script (`rm ~/bin/NAME` to reverse).
-   **Import one**: Run `installables import NAME` to move a script from
    `~/bin/` into the repo's `bin/` and symlink back.
-   **See Ignored**: Run `installables ignored` to see which scripts you
    have previously chosen to exclude from sync.
-   **Help**: Run `installables help` for a full usage summary.

## Homebrew Maintenance

The `login-utils` environment relies on a `brewfile` to track dependencies. 
There are three ways to check your Homebrew status:

1.  **`brew-check` (Fast)**: This is the default check run at shell startup. It 
    uses the `check-brew.sh` script to verify that the required formulae, 
    casks, and taps exist on your disk. It is very fast because it does not 
    call the `brew` command itself.
2.  **`brew-check-full` (Authoritative)**: This calls `brew bundle check`. It is 
    slower but more thorough, as it checks for correct versions and more 
    complex dependency states.
3.  **`br-i` (Install/Fix)**: If dependencies are missing, run `br-i` to 
    install them based on the `brewfile`. Use `br-i --upgrade` if you also 
    want to upgrade existing packages.

## Rogue Additions to Shell Init

Install scripts for CLI tools often append lines to `~/.bashrc` or
`~/.bash_profile` — adding PATH entries, sourcing completions, or running
init hooks. These rogue additions bypass our managed structure and can cause
surprising behavior (interactive prompts during shell init, duplicate PATH
entries, etc.).

Periodically check `~/.bashrc` and `~/.bash_profile` for lines added by
installers. Common patterns to look for:

-   **PATH additions**: Prefer symlinking the binary into `~/bin/` (which is
    already on PATH) and removing the added `export PATH=...` line.
-   **Completion scripts**: Symlink the completion file into
    `~/.local/share/bash-completion/completions/` (the standard user
    directory for bash-completion 2.x) and remove the `source ...` or
    `[[ -f ... ]] && source ...` line. Completions there are lazy-loaded
    automatically.
-   **Tool init hooks** (e.g. `eval "$(tool init bash)"`): Evaluate whether
    these belong in `bashrc.d/env-interactive` or can be replaced with a
    simpler setup.

## Git Configuration Sync

You likely have global git settings in `~/.gitconfig` that would be useful to 
share across all your environments.

### Identifying Shared Config

Check your `~/.gitconfig` for:
-   Aliases (`[alias]`)
-   Global ignore files (`[core] excludesfile`)
-   Tool preferences (`[merge] tool`, `[diff] tool`)

### Moving to `login-utils`

1.  Add these settings to the `git-config` file in this repository.
2.  In your `~/.gitconfig`, include the repository's config file:
    ```ini
    [include]
        path = ~/code/login-utils/git-config
    ```

This keeps your "personal" git identity (like `user.email`) separate from 
your "shared" workflow (like aliases).
