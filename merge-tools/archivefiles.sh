#!/bin/bash

NO_APP_NECESSARY=x

source source.sh
STATUS=$?
if [[ "$STATUS" != "0" ]] ; then exit $STATUS ; fi

if [[ -z "$NO_APP" ]] ; then
    echo are you sure\?
    wait


    echo totes sure\?
    wait

    echo One more time, confirm for me
    wait
fi

archive "$@"
