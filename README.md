# cygnix-enviro-utils

This is a storage place and show-off repository for the accumulated utilities
I'ver written over time to accommodate common tasks in Unix and Cygwin.

The tasks are organized according to what is generally unix-usable, what is
specific to Cygwin, and what is specific to work (most or all of which likely
will not make it up here).

# TL;DR on Mac

The very basics:
* `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
* `brew install bash`
* add /usr/local/bin/bash to /etc/shells
* `chsh /usr/local/bin/bash`
* start new terminal
* `ssh-keygen` and add resulting public key to github and anywhere else
* `brew install git --with-openssl --with-curl`
* `git clone git@github.com:jpassaro/cygnix-enviro-utils.git ~/code/login-utils`
* `ln -sv ~/code/login-utils/global-gitignore ~/.gitignore`
* `git config --global include.path ~/code/login-utils/git-config`
* `mkdir -p ~/bin ~/.ssh`
* `chmod 700 ~/.ssh`
* `echo source ~/code/login-utils/bashrc >>~/.bash_profile && source ~/.bash_profile`

For long-term / optional stuff:
* `ls ~/code/login-utils/bin` and symlink any of interest into `~/bin`
* `echo export GITHUB_API_TOKEN=[your token here] >> ~/.bash_profile`
* create .ssh/config including
```
Host gh
  Hostname github.com
  User git
```

Good things to brew install:
* `coreutils`
* `findutils`
* `gnu-{set,tar,time,units}`
* `less`
* `lesspipe`
* `ack` -- also `ln -sv ~/code/login-utils/ackrc ~/.ackrc`
* `vim` -- also:
  * `git clone gh:VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`
  * `echo source ~/code/login-utils/vimrc >> ~/.vimrc`
  * `vim +PluginInstall
* `jq` aka sed for json -- also `ln -sv ~/code/login-utils/custom.jq`
* `python` (a few executables depend on it)
* `python@2` if any of your projects use python2 (mac's python2 is Too Old)
* `graphviz` -- see also bin/dot-pipe for a nice vim integration
* `bash-completion` (lots of nice bash completions)
* `httpie`
* `thefuck`
* `ssh-copy-id`
* `pstree`
* `ascii`
* `awscli`

# Copyright

All code is copyright John Passaro 2017-2019 and released under the GPL. See LICENSE.
