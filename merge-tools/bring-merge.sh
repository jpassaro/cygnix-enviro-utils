#!/bin/bash

source source.sh
STATUS=$?
if [[ "$STATUS" != "0" ]] ; then exit $STATUS ; fi

if ! [[ "$1" =~ ^-?[0-9]+$ ]] ; then
  ( echo give me an integer revision, not this \""$1"\" bullshit
    echo usage: $0 '(ps|common)' REVISION ) >&2
  exit 1
fi

export REV=$1
shift

while [[ -n "$1" ]] ; do 
  if [[ record-only == $1* ]] ; then
    ARGS="$ARGS --record-only" ; shift
  elif [[ dry-run == $1* ]] ; then
    ARGS="$ARGS --dry-run" ; DRYRUN=dryrun ; shift
  fi
done

if ! checkmsg ; then exit 1 ; fi

if [[ "$(svnst -v | grep -v ^? | awk '$0=$1' | uniq | wc -l)" != 1 ]] ; then
	_svn update 
fi


if ! _svn merge $ARGS --accept postpone -c$REV $BRANCHURL ; then
  echo merge failed >&2 ; exit 1
fi

[ -z "$DRYRUN" ] && ( 
  echo "Merged revision $REV from $BRANCH:" 
  [[ -z "$ARGS" ]] || echo "(record-only)"
  _svn log -r$REV $BRANCHURL | egrep -v '^(r[0-9]* \| |-*$)' 
  echo ........ 
) | createcommit
