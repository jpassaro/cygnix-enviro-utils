#!/bin/bash
# shellcheck disable=SC1090
## the hashbang is given for filetype detection; however,
## this file should be installed as, or sourced from, your ~/.bashrc,
## and not run directly.

# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" == *i* ]] || return

if [[ "${BASH_VERSINFO[0]}" -lt 4 ]] ; then
  echo >&2 "Your bash version ($BASH_VERSION) is too low."
  echo >&2 "You need to upgrade to at least 4 to use john's login utils."
  return
fi

# detect system type
jp_system_type="$(uname -s)"
case "${jp_system_type,,}" in
  *cyg*) jp_system_type=cygwin ;;
  *linux*) jp_system_type=linux ;;
  *darwin*) jp_system_type=darwin ;;
  *) jp_system_type="UNKNOWN:${jp_system_type}"
esac


# source all relevant subscripts. possible examples:
# - bashrc.d/paths
# - bashrc.d/env
# - bashrc.d/aliases
# - bashrc.d/functions
# - bashrc.d/ssh-agent-settings
# It will ignore any subscript whose name begins with _.

unset PRAGMA_IMPORTED  # previously was in reload-profile only, trying it here
declare -A PRAGMA_IMPORTED
PRAGMA_INDEX=0

MY_BASHRC_FILE="${BASH_SOURCE[0]}"
MY_BASHRC_D="${MY_BASHRC_FILE}.d"

function source_pragma_once() {
  local sourceable
  for sourceable ; do
    if [[ -z "${PRAGMA_IMPORTED[$sourceable]}" &&
         "$(basename "$sourceable")" != _* ]]
    then
      if [[ -e "$sourceable" ]] ; then
        PRAGMA_IMPORTED["$sourceable"]=$((PRAGMA_INDEX++))
        echo "sourcing $sourceable"
        source "$sourceable"
      elif [[ "$sourceable" == */bashrc.d/* ]] ; then
        echo "could not find ${sourceable##*/bashrc.d/} in ${MY_BASHRC_D}"
      else
        echo "$sourceable could not be found, consider installing it"
      fi
    fi
  done
}

function check-for-package() {
  local optional
  while [[ "$1" == -* ]] ; do
    case "$1" in
      --optional)
        optional=yes
        shift
        ;;
      *)
        echo unrecognized option "$1"
        return 1
        ;;
    esac
  done
  local target="$1"
  local package="$2"
  if command -v "$target" >/dev/null 2>&1 ; then
    return 0
  elif [[ -z "$optional" ]] ; then
    echo "$target" not found, please install "${package:-it}"
  fi
  return 1
}

if [ -d "$MY_BASHRC_D" ] ; then
  echo "$MY_BASHRC_D" found
  source_pragma_once "$MY_BASHRC_D"/*
else
  echo "no bashrc.d found"
fi

function reload-profile() {
  # unset PRAGMA_IMPORTED # currently trying at top of file
  # shellcheck source=./bashrc
  source "$MY_BASHRC_FILE"
}
