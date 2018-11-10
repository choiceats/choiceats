#!/bin/sh

SRC="src/assets/"
DIST="dist/"
NUM_FILES=$(find $SRC -type f | wc -l)

echo
echo "Copying $NUM_FILES files from $SRC to $DIST..."
cp -r $SRC $DIST
echo "Successfully copied files."
