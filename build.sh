#!/bin/sh

set -e

js="tmp.js"
min="dist/app.js"
min_tmp_gzip="dist/app_tmp_for_gzip.js"
min_tmp_gzipped="dist/app_tmp_for_gzip.js.gz"
min_gzip="dist/app.js.gz"

echo "Making elm distribution file..."
echo

elm make --optimize --output=$js src/Main.elm $@

echo
echo "Minifying, uglifying, and removeng dead code from bundle..."
echo

uglifyjs $js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=$min

brotli --force $min

cp $min $min_tmp_gzip
gzip $min_tmp_gzip
mv $min_tmp_gzipped $min_gzip


echo "Successfully optimized bundle:"
echo "------------------------------"
echo "Compiled: $(cat $js | wc -c) bytes"
echo "Minified: $(cat $min | wc -c) bytes"
echo "Gzipped:  $(cat $min | gzip -c | wc -c) bytes"
echo
echo "Bundle written to $min, $min.br, and $min_gzip."
echo

rm $js
