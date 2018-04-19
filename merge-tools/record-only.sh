#!/bin/bash

source source.sh
STATUS=$?
if [[ $STATUS != 0 ]] ; then exit $STATUS ; fi

checkmsg || exit 1

[[ -e "$MERGEFILE" ]] || create_merge_log revision "$@"

record_only_merge

[[ -n "$FORCE" ]] || create_merge_commit
