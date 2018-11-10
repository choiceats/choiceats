#!/bin/sh

inotifywait \
  --event create \
  --event delete \
  --event modify \
  --event move \
  --exclude "\.sw[a-z]$" \
  --format '%:e %f' \
  --monitor \
  --recursive \
  src/ | \
  ./burst.sh 1 './copy-static.sh && ./build-dev.sh'

# Can use this to do something on every event
# while read event file; do
#    echo "$event:$file"
# done
