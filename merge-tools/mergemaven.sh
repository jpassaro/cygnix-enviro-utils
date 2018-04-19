#!/bin/bash

source source.sh
STATUS=$?
if [[ $STATUS != 0 ]] ; then exit $STATUS ; fi

if ! checkmsg ; then exit 1 ; fi

set -e

MVNPRFX="\[maven-release-plugin\]"

if [[ -e "$MERGEFILE" ]] ; then
  echo >&2 "$MERGEFILE" already exists.
  echo >&2 run ./revert or ./archive or use ./force-record-only.sh
  exit 1
fi
  
create_merge_log search "$MVNPRFX" "$@"

record_only_merge
  
create_merge_commit searching for "$MVNPRFX" "$@"