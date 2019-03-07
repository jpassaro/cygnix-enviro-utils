#!/usr/bin/env bash

thisscript="$0"
anyfailed=
quiet=
input=

function fail() {
  [[ -n "$quiet" ]] || echo "$@"
  anyfailed=yes
}

function usage() {
  [[ "$#" == 0 ]] || echo >&2 Error: "$@"
  echo >&2 "usage: ${thisscript} [--quiet] [-f brewfile]"
  exit 127
}

while [[ "$#" -gt 0 ]] ; do
  case "$1" in
    --quiet)
      quiet=yes
      ;;
    -f) shift ; input="$1" ;;
    -f*) input="${1#-f}" ;;
    *) usage "Invalid argument ${1}" ;;
  esac
  shift
done

if [[ -n "$input" && ! -r "$input" ]] ; then
  usage "${input} cannot be read"
elif [[ -z "$input" && -t 0 ]] ; then
  usage 'must provide brewfile via stdin or -f'
fi

while read -r entrytype qformula ; do
  formula="${qformula#\"}"
  formula="${formula%%\"*}"
  case "$entrytype" in
    brew)
      [[ -d /usr/local/Cellar/"${formula##*/}" ]] ;;
    tap)
      [[ -d /usr/local/Homebrew/Library/Taps/"${formula%%/*}/homebrew-${formula#*/}" ]] ;;
    cask)
      [[ -d /usr/local/Caskroom/"${formula}" ]] ;;
    *)
      fail "I don't know how to read '${entrytype}' entries." ;;
  esac || fail "${entrytype} '${formula}' is not installed."
done < <(sed 's/[ ]*#.*//' ${input:+"$input"} | grep .)

if [[ -z "$anyfailed" ]] ; then
  fail all dependencies satisfied.
else
  fail not all dependencies have been satisfied.
  exit 1
fi
