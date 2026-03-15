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
echo source ~/code/login-utils/bashrc >>~/.bash_profile
```

When you're ready to roll, start a new terminal or call `source
~/.bash_profile`. The utilities should make further suggestions from here.

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
