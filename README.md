# cygnix-enviro-utils

This is a storage place and show-off repository for the accumulated utilities
I've written over time to accommodate common tasks in Unix and Cygwin.

## Quick Start

1.  **Install**: See [INSTALL.md](INSTALL.md) for Homebrew, Bash, and SSH setup.
2.  **Configure**: Clone this repo and source the `bashrc` in your profile.
3.  **AI Integration**: This repo is assistant-agnostic. See [AGENTS.md](AGENTS.md)
    for instructions on how to link your AI agent (Gemini, Claude) to the
    portable skills and habits in the `agent/` directory.

## Core Components

- **bin/**: Stable utility scripts.
- **bashrc.d/**: Modular bash configuration (paths, env, aliases, completions).
- **agent/**: Portable AI agent plugin (skills, hooks, and AGENTS.md rules).

## Managing Utilities

New scripts go to `~/bin/` first for iteration. Once stable, migrate them
to `login-utils/bin/` and symlink back from `~/bin/`.

The `installables` bash function (defined in `bashrc.d/installables`)
manages the sync between the two directories. Run it with no arguments to
see what's out of sync, or `installables interactive` to walk through
each item. It runs in quiet mode on shell startup and prints a one-line
summary when action is needed.

---
Copyright John Passaro 2017-2026. Released under the GPL. See LICENSE.
