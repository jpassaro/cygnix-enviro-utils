# Installation

This guide covers the technical setup for `cygnix-enviro-utils`.

## Homebrew (Mac only)

To use this on Mac, install homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Note:** The installer will suggest adding an `eval` of `brew shellenv` to
your `.bash_profile`. You can ignore this; the `bashrc` in this repository
handles Homebrew initialization automatically once it is sourced.

## Update bash

Modern macOS defaults to `zsh`. These utilities are Bash-based and cannot be
used in zsh. Furthermore, they require features introduced in **Bash 4.x or
higher**, while Macs generally come with a bash in the 3.x series which is
incompatible with these utilities. Therefore we will need to install a custom
bash and make it the default shell.

1.  **Install modern Bash**:
    `brew install bash`

2.  **Add to allowed shells**:
    Add the new bash (with brew this is "$(brew --prefix)/bin/bash") to
    `/etc/shells`.

3.  **Change your default shell**:
    ```bash
    chsh -s "$(brew --prefix)/bin/bash"
    ```

Now start a new terminal; it should use the new bash. You can verify with
`echo $BASH_VERSION`.

## Git bare-bones
Create or update `.ssh/config` including
```console
$ mkdir -p ~/.ssh && chmod 700 ~/.ssh
$ cat >>~/.ssh/config <<EOF
Host gh
  Hostname github.com
  User git
  StrictHostKeyChecking yes

Host jsharp
  <you know what to put here>
  StrictHostKeyChecking yes
EOF
```

Create or update `.ssh/known_hosts` including the current GitHub host keys:
```
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmUMZhfDqnNoeWk1X1qdzJLUmS5eXU8T9QOq4G3v6vG59S9QO6j+U8C9P3K9m/7yO4P2l9m9N/6M=
```

Use `ssh-keygen -t ed25519` to create a modern SSH keypair. Add the public
key to your GitHub settings.

Now you can clone and push to github repos quickly, efficiently, and without
entering a password:
`git clone gh:jpassaro/cygnix-enviro-utils.git ~/code/login-utils`

## Including bashrc

If you don't already have git, install it. Then clone this:

```console
git clone gh:jpassaro/cygnix-enviro-utils.git ~/code/login-utils
```

### Profile vs. Bashrc

Bash uses two main configuration files, and the rules for when it reads which one
can be confusing:

-   **`.bash_profile`**: Read by **login shells** (e.g., when you first log in, 
    or when you open a new terminal window on **macOS**).
-   **`.bashrc`**: Read by **non-login interactive shells** (e.g., when you 
    start a sub-shell by typing `bash`).

To ensure a consistent environment across all types of interactive shells, the 
standard practice is to put all configuration in `.bashrc` and have 
`.bash_profile` source it.

Add the following to your `~/.bashrc`:
```bash
# Source the login-utils bashrc
if [ -f ~/code/login-utils/bashrc ]; then
    source ~/code/login-utils/bashrc
fi
```

Then, add the following to your `~/.bash_profile` to ensure `.bashrc` is 
always loaded:
```bash
# Load .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
```

When you're ready to roll, start a new terminal or call `source
~/.bashrc`. The utilities should make further suggestions from here.

## AI Integration

This repository provides a portable extension for AI agents (Gemini CLI and 
Claude Code) in the `agent/` directory. This extension bundles specialized 
skills, communication habits, and automatic hooks (like timestamps).

### Installation

-   **Gemini CLI**: the extension is installed in a persistent fashion.
    Normally it's installed by version, but there is a symlink-based dev mode
    where changes become available immediately. Use this command:
    ```bash
    gemini extensions link ~/code/login-utils/agent
    ```
-   **Claude Code**: the plugin must be added to be around runtime. The
    `jp-claude` wrapper (in `bin/`) automatically adds `--plugin-dir
    ~/code/login-utils/agent` to every invocation. Just run
    `installables interactive` to ensure that jp-claude is installed
    properly. If so, then your next terminal session will alias
    claude=jp-claude and you should have the plugin available.

### Verification

To verify that the extension and its components are active, follow the checks
relevant to your environment:

#### For Users (Manual Check)
- **Gemini**: Run `gemini extensions list` and `gemini skills list`.
- **Claude**: Run `claude plugins list`.
- **Aliases**: In an interactive shell, run `type -a claude` to ensure it
  points to `jp-claude`. (Aliases are intentionally not exported to
  non-interactive shells, so this check only works from a terminal prompt.)

#### For AI Agents (Self-Diagnostic)
If you are an AI assistant working in this repo, you MUST verify your own
integration:

1.  **Extensions/Plugins**: Check if you have been started with the
    `jp-login-utils` extension (Gemini) or plugin (Claude).
2.  **Skills**: Check your internal skill-listing (e.g., `gemini skills list`)
    to ensure the skills in `agent/skills/` are discovered and enabled.
3.  **Hooks**: Check your own conversation context for a `Current Time: ...`
    line injected with or just after the user's prompt, including a timezone
    offset (not UTC). If it is present, the timestamp hook is active.

**Note:** Agents cannot verify the `claude` → `jp-claude` alias directly
(non-interactive shell). If the plugin and hooks checks pass, the alias
was working when the session was launched.

### Hooks

Gemini CLI discovers hooks automatically from `agent/hooks/hooks.json` when
the extension is installed. Claude Code does not have an equivalent
auto-discovery mechanism — hooks must be registered manually in
`~/.claude/settings.json` (global) or `.claude/settings.json` (project).

For example, to register the timestamp-injector hook for Claude Code, add a
`UserPromptSubmit` entry to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/code/login-utils/agent/hooks/user-prompt-timestamp.sh"
          }
        ]
      }
    ]
  }
}
```

### User-level instructions

`~/.claude/CLAUDE.md` and `~/.gemini/GEMINI.md` are loaded at higher
priority than the plugin's `AGENTS.md`. They are workstation-specific and
should not be copied verbatim between machines. Use them for:

- **Session-start protocols** — which skills to invoke on first message,
  with a pointer to the urgency-signal policy in `AGENTS.md`.
- **Workstation-specific context** — employer URLs, desk paths, tool
  aliases, or other details that vary per machine.
- **Overrides** to plugin defaults that apply only on this machine.

Do not duplicate portable conventions here — those belong in
`agent/AGENTS.md`.

### Communication Style & Habits

The extension automatically loads `agent/AGENTS.md`, which contains 
instructions for communication style, bash habits, and engineering standards. 
You do not need to import this file manually.

### Hooks & Time Awareness

The extension includes a `timestamp-injector` hook that automatically injects 
`[Current Time: ...]` into your conversations. This is used by skills like 
`soft-timebox` and `end-of-day-awareness`.

### Agent CLI wrappers (`gitdir`, `ghe`)

Two scripts in `bin/` provide read-only wrappers that simplify AI agent
permissions:

- **`gitdir`** — wraps `git -C` for operating on repos outside the CWD.
  Grant the same read-only subcommands you allow for bare `git`:
  ```json
  "Bash(gitdir fetch:*)",
  "Bash(gitdir log:*)",
  "Bash(gitdir status:*)",
  "Bash(gitdir diff:*)",
  "Bash(gitdir show:*)",
  "Bash(gitdir blame:*)",
  "Bash(gitdir worktree:list:*)",
  "Bash(gitdir rev-parse:*)",
  "Bash(gitdir config:get:*)",
  "Bash(gitdir ls-tree *)"
  "Bash(gitdir cat-file *)"
  ```
- **`ghe`** — wraps `gh` for read-only GitHub Enterprise operations
  (PR views, diffs, API GETs, browse). Avoids the `GH_HOST` env var
  complication that breaks permissions patterns. Grant per-command:
  ```json
  "Bash(ghe *)",
  ```

Install both via `installables install gitdir ghe`.

## Editor configuration

Add the following to your `~/.vimrc`:
```bash
source ~/code/login-utils/vimrc
```

For neovim, symlink the init file (or source it from an existing one):
```bash
mkdir -p ~/.config/nvim
ln -sf ~/code/login-utils/nvim-init.vim ~/.config/nvim/init.vim
```

The nvim config sources `~/.vimrc` and adds COLORFGBG-based light/dark
background detection (which neovim does not do natively).

## Other bits of setup

It's a good idea to supply a github API token in your private `.bash_profile`
for various tools. For brew, `GITHUB_API_TOKEN`; for `gh`, GitHub's CLI,
`GITHUB_TOKEN`.

### mac specific

On safari, remember to set the search engine to DuckDuckGo, and to set tab to
highlight all controls instead of just text.

On iterm, set the keyboard shortcuts using the preset about text editing.

remember to download dash and use your license at 

### jsharp

```console
$ ssh-keyscan <redacted> | sort | tee /tmp/jsharp.pub
...
$ ssh-keygen -lf /tmp/jsharp.pub
256 SHA256:Noa8jZJuGiUPpmXQc78OO01+pYUypEyBtbGqm01P0H0 <redacted> (ECDSA)
256 SHA256:eaci49zRni6zaA63T3EPtoeLkYw4mOby9DewwrXc7c0 <redacted> (ED25519)
3072 SHA256:o3PYcOZ6NMrJqkbR00Megwy8UOtKq1GbLpGvbxyES/A <redacted> (RSA)
$ cat /tmp/jsharp.pub >> ~/.ssh/known_hosts
$ cat >>~/.ssh/config <<EOF
Host jsharp
  HostName ...
  User ...
  IdentityKey ...
  StrictHostKeyChecking yes
  PasswordAuthentication no
...
```
