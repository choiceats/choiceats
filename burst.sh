#!/bin/bash

# Only do something at most every INTERVAL seconds
# Whether sleep accepts decimals or not is implementation specific

help() {
    >&2 echo "Usage: $0 <interval> <command>"
}

set -e
trap help EXIT
interval=${1:?missing interval}; shift
: ${1:?missing command}

trap - EXIT
set +e
exec 3> >(sed "s/^/burst: /" >&2)
while read line; do
    echo "$line" >&3
    test -n "$!" && kill -term $! 2>/dev/null
    (sleep $interval && $SHELL -c "$*") &
done
