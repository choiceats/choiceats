#!/bin/sh

elm-live --output=dist/elm.js src/Main.elm --dir=dist/ --before-build=clear --pushstate --open --debug
