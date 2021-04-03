#!/bin/sh

ytLink=$1
output=$2
format=$3
ptac="/home/t2x/doscricon/scripts/pic-to-album-cover.sh"

echo "[ytttac] Downloading source thumbnail..."

[ -z "$output" ] && output="thumbnail"
youtube-dl $1 --skip-download --write-thumbnail --quiet --write-info-json -o "$output"

# check if the cover downloaded has 1280 width (as should be)
thumbnailLink=$(jq -r ".thumbnail" "$output.info.json")
thumbnailExtension="${thumbnailLink##*.}"
originalWidth=$(identify -format '%w' "$output.$thumbnailExtension")
[ "$originalWidth" -lt 1280 ] && echo "Downloaded thumbnail is small!"

[ -f "$output.info.json" ] && rm "$output.info.json"
! [ -z "$format" ] && sh $ptac "$output.$thumbnailExtension" "$format"
