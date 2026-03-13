#!/bin/bash
# shellcheck disable=SC1090
## the hashbang is given for filetype detection; however,
## this file should be installed as, or sourced from, your ~/.bashrc,
## and not run directly.

# User dependent .bashrc file

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
JP_LOGIN_UTILS="$(cd "$(dirname "$MY_BASHRC_FILE")" && pwd -P)"
export JP_LOGIN_UTILS

function source_pragma_once() {
  local sourceable
  for sourceable ; do
    if [[ -z "${PRAGMA_IMPORTED[$sourceable]}" &&
         "$(basename "$sourceable")" != _* ]]
    then
      if [[ -e "$sourceable" ]] ; then
        PRAGMA_IMPORTED["$sourceable"]=$((PRAGMA_INDEX++))
        [[ "$-" != *i* ]] || echo >&2 "sourcing $sourceable"
        source "$sourceable"
      elif [[ "$sourceable" == */bashrc.d/* ]] ; then
        echo >&2 "could not find ${sourceable##*/bashrc.d/} in ${MY_BASHRC_D}"
      else
        echo >&2 "$sourceable could not be found, consider installing it"
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

# --- non-interactive setup ---
# PATH, key exports, and ssh agent env are useful in non-interactive shells too.

if [ -d "$MY_BASHRC_D" ] ; then
  source_pragma_once "$MY_BASHRC_D"/path
  mkdir -p ~/bin
  prepend-path ~/bin
  source_pragma_once "$MY_BASHRC_D"/env
  source_pragma_once "$MY_BASHRC_D"/cyg-env
fi

# pick up ssh agent env vars (PID, socket) for non-interactive use (e.g. git over ssh).
# the full agent startup/key-adding logic in ssh-agent-settings runs interactively only.
SSH_HOME="${SSH_HOME:-"$HOME"/.ssh}"
SSH_ENV="${SSH_ENV:-${SSH_HOME}/agent-setup}"
[[ ! -f "$SSH_ENV" ]] || source "$SSH_ENV"

# --- end non-interactive setup ---
[[ "$-" == *i* ]] || return

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
