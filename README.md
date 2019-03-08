# cygnix-enviro-utils

This is a storage place and show-off repository for the accumulated utilities
I'ver written over time to accommodate common tasks in Unix and Cygwin.

The tasks are organized according to what is generally unix-usable, what is
specific to Cygwin, and what is specific to work (most or all of which likely
will not make it up here).

# Homebrew (Mac only)

To use this on Mac, install homebrew:
`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

# Update bash

On some systems (Mac especially) you will need to start by updating bash.
If your bash is less than 4.4 or so, install the up to date one using your
system's package manager. For example `brew install bash`;

Add the new bash (with brew this is /usr/local/bin/bash) to /etc/shells,
and choose it using `chsh`.

Now start a new terminal; it should use the new bash.

# Git bare-bones
Create .ssh/config including
```
Host gh
  Hostname github.com
  User git
```

Use `ssh-keygen` to create a public key and add it to github. Optionally
add it to the `gh` ssh host you just created.

Now you can clone git repos quickly:
`git clone gh:jpassaro/cygnix-enviro-utils.git ~/code/login-utils`

# Including bashrc

If you don't already have git, install it.
(On mac: `brew install git --with-openssl --with-curl`

```console
git clone git@github.com:jpassaro/cygnix-enviro-utils.git ~/code/login-utils
echo source ~/code/login-utils/bashrc >>~/.bash_profile
```

When you're ready to roll, start a new terminal or call `source
~/.bash_profile`. The utilities should make further suggestions from here.

# Other bits of setup

It's a good idea to supply a github API token in your private `.bash_profile`
for various tools. For brew, `GITHUB_API_TOKEN`; for `hub`, Github's CLI,
`GITHUB_TOKEN`.

# Copyright

All code is copyright John Passaro 2017-2019 and released under the GPL. See LICENSE.
