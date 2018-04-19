#!/bin/bash

source source.sh
STATUS=$?
if [[ "$STATUS" != "0" ]] ; then exit $STATUS ; fi

if [[ ! -f $MSGFILE ]] ; then
  echo there appears to be nothing to check in\; $MSGFILE is missing. >&2
  exit 1
fi

if [[ ! -f $DIFFFILE ]] ; then
  echo looks like you never diffed this. shame on you\! please run ./status.sh >&2
  exit 1
fi

echo about to check in the following comment:
echo
cat $MSGFILE
echo
wait

THEDATE="`date +%F_%T`"

if ! _svn ci -F $MSGFILE ; then
  echo check-in failed >&2 ; exit 1
fi

_svn up -q

archive
