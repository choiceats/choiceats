#!/bin/sh

function before_build_function {
    cp src/assets/index-elm.html dist/index.html
    yarn build-elm
}

before_build_function

# TODO: Figure out how to run a locally defined shell function with --before-build.
# Passing the function to before_build does not work.
# This approach of running before_build_function once on start
# works fine if you are only working on elm files.
# If working on js/css/html/scss files, you have to restart the process.

elm-live \
    --output=dist/elm-dev-bundle.js \
    src/Main.elm \
    --dir=dist/ \
    --before-build=clear \
    --pushstate \
    --open \
    --debug
