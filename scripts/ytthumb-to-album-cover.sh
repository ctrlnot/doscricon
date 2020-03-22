#!/bin/sh

ytLink=$1
output=$2
format=$3
ptac="/home/t2x/doscricon/scripts/pic-to-album-cover.sh"

echo "[ytttac] Downloading source thumbnail..."

[ -z $output ] && output="thumbnail.jpg"
youtube-dl $1 --skip-download --quiet --write-thumbnail -o $output

# check if the cover downloaded has 1280 width (as should be)
originalWidth=$(identify -format '%w' $output)
[ "$originalWidth" -lt 1280 ] && echo "Downloaded thumbnail is small!"

! [ -z $format ] && sh $ptac $output $format
