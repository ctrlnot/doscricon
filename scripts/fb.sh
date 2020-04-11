#!/bin/sh

youtube-dl "$1" --add-metadata -o "fb" --print-json > fb.json

fbname=$(echo $(jq -r ".webpage_url" fb.json) | cut -d "/" -f 4)
title=$(jq -r ".uploader" fb.json)
ext=$(jq -r ".ext" fb.json)
id=$(jq -r ".id" fb.json)
output="$fbname - $title - $id.$ext"

cp "fb.$ext" "$output"
[ -f fb.json ] && rm fb.json
[ -f "fb.$ext" ] && rm "fb.$ext"
