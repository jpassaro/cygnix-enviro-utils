# Installation

This guide covers the technical setup for `cygnix-enviro-utils`.

## Homebrew (Mac only)

To use this on Mac, install homebrew:
`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

## Update bash

On some systems (Mac especially) you will need to start by updating bash.
If your bash is less than 4.4 or so, install the up to date one using your
system's package manager. For example `brew install bash`;

Add the new bash (with brew this is "$(brew --prefix)"/bin/bash) to /etc/shells,
and choose it using `chsh`.

Now start a new terminal; it should use the new bash.

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

Create or update `.ssh/known_hosts` including
```
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
```

Use `ssh-keygen` to create an SSH keypair. Point to that key in the `gh` ssh
host config you just created, and add the public key to your github settings.

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
