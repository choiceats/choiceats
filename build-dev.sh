#!/bin/sh

set -e

dest="dist/app.js"
SRC="src/assets/"
DIST="dist/"

mkdir -p $DIST

echo
echo "Copying from $SRC to $DIST..."
cp $SRC/* $DIST
echo

echo "Making elm distribution file..."
echo

./node_modules/.bin/elm make --output=$dest src/Main.elm $@

echo
echo "Bundle written to $dest"
echo
echo rebuilt at $(date)
echo
