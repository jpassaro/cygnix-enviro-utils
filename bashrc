## this file should be installed as, or sourced from, your ~/.bashrc

# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# source all relevant subscripts. possible examples:
# - bashrc.d/paths
# - bashrc.d/env
# - bashrc.d/aliases
# - bashrc.d/functions
# - bashrc.d/ssh-agent-settings
# It will ignore any subscript whose name begins with _.

declare -A PRAGMA_IMPORTED
let PRAGMA_INDEX=0

function source_pragma_once() {
  for sourceable ; do
    if [[ -z "${PRAGMA_IMPORTED[$sourceable]}" &&
         -e "$sourceable" &&
         "$(basename $sourceable)" != _* ]] ; then
      PRAGMA_IMPORTED["$sourceable"]=$((PRAGMA_INDEX++))
      echo "sourcing $sourceable"
      source "$sourceable"
    else
      echo "skipping $sourceable"
    fi
  done
}

if [ -d $HOME/bashrc.d ] ; then
  echo $HOME/bashrc.d found
  source_pragma_once $HOME/bashrc.d/*
fi



