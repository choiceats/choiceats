#!/bin/sh

set -e

dest="dist/app.js"

echo "Making elm distribution file..."
echo

elm make --output=$dest src/Main.elm $@

echo
echo "Bundle written to $dest"
echo
