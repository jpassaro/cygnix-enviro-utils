# cygnix-enviro-utils

This is a storage place and show-off repository for the accumulated utilities
I'ver written over time to accommodate common tasks in Unix and Cygwin.

The tasks are organized according to what is generally unix-usable, what is
specific to Cygwin, and what is specific to work (most or all of which likely
will not make it up here).

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

# TODO:

* try out the stuff in https://github.com/Russell91/sshrc and make sure it
  plays nice with this...

# Copyright

All code is copyright John Passaro 2016 (or date of last file modification),
and released under the GPL. See LICENSE.
