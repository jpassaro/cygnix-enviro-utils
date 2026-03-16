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
    `check-installables interactive` to ensure that jp-claude is installed
    properly. If so, then your next terminal session will alias
    claude=jp-claude and you should have the plugin available.

### Verification

After installing, verify that the skills and hooks are active:

1.  **Installation/linkage**: use CLI sub-commands to ensure the plugin and
    its skills and hooks are accessible, depending on which agent you're using:
    * `gemini extensions list`
    * `gemini skills list`
    * `claude plugins list`
    * `type -a claude` (should show jp-claude past the alias).
2.  **Hooks**: Start a new session and ask the assistant for the time.
    It should have a timestamp (local, not UTC) printed into its context,
    approximately like this: `[Current Time: ...]`

### Communication Style & Habits

The extension automatically loads `agent/AGENTS.md`, which contains 
instructions for communication style, bash habits, and engineering standards. 
You do not need to import this file manually.

### Hooks & Time Awareness

The extension includes a `timestamp-injector` hook that automatically injects 
`[Current Time: ...]` into your conversations. This is used by skills like 
`soft-timebox` and `end-of-day-awareness`.

## Other bits of setup

It's a good idea to supply a github API token in your private `.bash_profile`
for various tools. For brew, `GITHUB_API_TOKEN`; for `hub`, Github's CLI,
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
