#!/bin/bash
## the above for vim filetype detection; however,
## this file should be installed as, or sourced from, your ~/.bashrc

# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" == *i* ]] || return

if [[ "${BASH_VERSINFO[0]}" -lt 4 ]] ; then
  echo >&2 "Your bash version ($BASH_VERSION) is too low."
  echo >&2 "You need to upgrade to at least 4 to use john's login utils."
  return
fi

# source all relevant subscripts. possible examples:
# - bashrc.d/paths
# - bashrc.d/env
# - bashrc.d/aliases
# - bashrc.d/functions
# - bashrc.d/ssh-agent-settings
# It will ignore any subscript whose name begins with _.

unset PRAGMA_IMPORTED  # previously was in reload-profile only, trying it here
declare -A PRAGMA_IMPORTED
let PRAGMA_INDEX=0

function source_pragma_once() {
  local sourceable
  local source_result
  for sourceable ; do
    if [[ -z "${PRAGMA_IMPORTED[$sourceable]}" &&
         "$(basename $sourceable)" != _* ]]
    then
      if [[ -e "$sourceable" ]] ; then
        PRAGMA_IMPORTED["$sourceable"]=$((PRAGMA_INDEX++))
        echo "sourcing $sourceable"
        source "$sourceable"
      elif [[ "$sourceable" == */bashrc.d/* ]] ; then
        echo "could not find ${sourceable##*/bashrc.d}, is ~/bashrc.d symlinked correctly?"
      else
        echo "$sourceable could not be found, consider installing it"
      fi
    fi
  done
}

function check-for-package() {
  local target="$1"
  local package="$2"
  if which "$target" >/dev/null 2>&1 ; then
    return 0
  else
    echo "$target" not found, please install "${package:-it}"
    return 1
  fi
}

if [ -d $HOME/bashrc.d ] ; then
  echo $HOME/bashrc.d found
  source_pragma_once $HOME/bashrc.d/*
else
  echo "no bashrc.d found"
fi

MY_BASHRC_FILE="${BASH_SOURCE[0]}"

function reload-profile() {
  # unset PRAGMA_IMPORTED # currently trying at top of file
  source "$MY_BASHRC_FILE"
}

# must be last for some reason...
if which -s direnv ; then
  eval "$(direnv hook bash)"
else
  echo "Please install direnv."
fi
