# cygnix-enviro-utils

This is a storage place and show-off repository for the accumulated utilities
I'ver written over time to accommodate common tasks in Unix and Cygwin.

The tasks are organized according to what is generally unix-usable, what is
specific to Cygwin, and what is specific to work (most or all of which likely
will not make it up here).

## Package installations

On Mac, several dependencies must be installed.

* __homebrew__: package manager. ``/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"``
* __bash__: Bash 4 is required. ``brew install bash``
* __git__ (optional): needed to take full advantage of shell completion and
  prompt features; however you can work just fine without it.
 ``brew install git``

## Commands

Several custom commands are provided in `bin` and `cygbin`. You may either add
these to your PATH or symlink the specific commands you want to your own
preferred PATH directory.

## Bash sources

A number of bash source stuff is provided that sets up custom functions,
aliases, PATH directories, and environment variables to make life easier. A
parent source file is also provided that quickly and without duplication
sources all of them: ./bashrc. To enable this:

1. create a symlink to ./bashrc.d in your home directory;
1. One of the following:
   1. `ln -s ${GIT_DIR}/bashrc ${HOME}/.bashrc`
   1. (recommended) `echo "source ${GIT_DIR}/bashrc >> ${HOME}/.bashrc`

This parent source file may be symlinked to ~/.bashrc, but the recommenmdation
is to source it directly *from* there instead, as this allows you to customize
settings to your own computer without syncing the changes to your git upstream.

## Git

A git config file is included which accomplishes two things:
* defines many useful aliases and short names for common commands
* replaces http github urls with the equivalent using ssh

Run the following to reference it:

    git config --global include.path ${GIT_DIR}/git-aliases

The following recommended symlink tells git to globally ignore any vim swap
files, and is automatically picked up via the aforementioned include:

    ln -s ${GIT_DIR}/global-gitignore ~/.gitignore

## Vim

A powerful Vim environment is included.

First, install Vundle:

     git clone git@github.com:VundleCVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

Then make sure your vimrc exists and loads the included one:

     echo "source ${GIT_DIR}/vimrc" >> ${HOME}/.vimrc

(As with bashrc it is possible in principle to symlink, but we recommend the
source command since it allows you to override for your local environment.)

Finally, use vim to install the needed plugins:

    vim +PluginInstall

## Custom executables

A number of useful executables are included in ``bin/``. Each one can be
read for documentation of what it does. To use them, do this:

    mkdir -p ~/bin && ln -s ${GIT_DIR}/bin/my-command ~/bin

The new directory ``~/bin`` is automatically included on your PATH.

# Copyright

All code is copyright John Passaro 2017 (or date of last file modification),
and released under the GPL. See LICENSE.
