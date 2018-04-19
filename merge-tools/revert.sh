#!/bin/bash
#set -x
source source.sh
STATUS=$?
if [[ "$STATUS" != "0" ]] ; then exit $STATUS ; fi

if [[ ! -f $MSGFILE && ! -f $MERGEFILE ]] ; then
  echo there appears to be nothing to revert\; $MSGFILE and $MERGEFILE are missing. >&2
  exit 1
fi

_svn revert --recursive . && rm -fv $MSGFILE $DIFFFILE $MERGEFILE