#!/bin/sh

elm-live --output=public/elm.js src/Main.elm --dir=public/ --before-build=clear --pushstate --open --debug
