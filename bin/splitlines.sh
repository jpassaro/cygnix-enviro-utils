#!/usr/bin/env bash

if [[ -t 0 ]] ; then
  echo >&2 "usage: $0 [printf_format]"
  echo >&2 'will print each line of stdin to a separate file'
  exit 1
fi

format="$1"
case "${format=$1}" in
  '') format=.json
    ;&
  .*)
    dir="$(mktemp -d)" || exit $?
    format="${dir}/result%04d.txt"
    ;;&
esac

## test input
uuid="$((0x$(uuidgen | tr -d -)))"
printf -v testval "$format" "$uuid"
case "$testval" in
  *"$uuid"*)
    ;;
  *)
    echo >&2 "format should have one printf target"
    exit 1
    ;;
esac

n=0
while read -r ; do
  printf -v target "$format" "$n"
  echo "$REPLY" >"$target"
  echo "$target"
  ((n+=1))
done
