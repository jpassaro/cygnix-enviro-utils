#!/bin/bash

source source.sh
STATUS=$?
if [[ $STATUS != 0 ]] ; then exit $STATUS ; fi

record_only_merge

checkmsg >/dev/null && create_merge_commit || echo using existing commit file
