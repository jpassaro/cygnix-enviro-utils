#!/bin/bash

source source.sh
STATUS=$?
if [[ "$STATUS" != "0" ]]; then exit $STATUS ; fi

svn up

mergeinfo | pipe2n++ $REVLIST >&2

seelog -v | pipe2n++ $REVLOG

echo done with $CODEBASE logging
