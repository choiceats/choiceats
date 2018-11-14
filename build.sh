#!/bin/sh

set -e

js="tmp.js"
min="dist/app.js"
min_tmp_gzip="dist/app_tmp_for_gzip.js"
min_tmp_gzipped="dist/app_tmp_for_gzip.js.gz"
min_gzip="dist/app.js.gz"

SRC="src/assets/"
DIST="dist/"


echo
echo "Copying from $SRC to $DIST..."
cp $SRC/* $DIST
echo
echo "Making elm distribution file..."
echo

./node_modules/.bin/elm make --optimize --output=$js src/Main.elm $@

echo
echo "Optimizing bundle..."
echo

./node_modules/.bin/uglifyjs $js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | ./node_modules/.bin/uglifyjs --mangle --output=$min

./node_modules/.bin/brotli-cli $min

cp $min $min_tmp_gzip
./node_modules/gzipme/bin/gzipme $min_tmp_gzip
mv $min_tmp_gzipped $min_gzip


echo "Optimized bundle written to $min, $min.br, and $min_gzip."
echo

rm $min_tmp_gzip $js
