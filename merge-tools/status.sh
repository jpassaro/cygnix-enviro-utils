#!/bin/bash

source source.sh
STATUS=$?
if [[ "$STATUS" != "0" ]] ; then exit $STATUS ; fi

svnst

if [[ -f $DIFFFILE ]] ; then
  echo using pre-existing diff $DIFFFILE
elif [[ ! -e $DIFFFILE ]] ; then
  _svn diff -x -w >$DIFFFILE
  echo created new diff $DIFFFILE
else
  echo what is this i can\'t even >&2 ; exit 1
fi

if [[ -s $DIFFFILE ]] ; then
  head -n 130 $DIFFFILE
  echo ; echo ; echo
  wc -l $DIFFFILE
  echo if the above number is larger than 130, you should n++ $DIFFFILE to see the whole thing
else
  echo $DIFFFILE is empty and will be erased.
  rm -vf $DIFFFILE
fi
