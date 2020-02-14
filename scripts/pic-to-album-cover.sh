#!/bin/bash

background="transparent"

if ! [ -z "$2" ]; then
  if ! [[ $2 =~ ^[0-9A-Fa-f]{6}$ ]]; then
    echo "Invalid hex value! $2"
    exit
  fi
  background="#$2"
fi


picWidth=$(identify -format '%w' $1)
extension="${1##*.}"
filename=$(basename $1 ".$extension")
outputFilename="$filename-cover.png"

convert -size "${picWidth}x${picWidth}" "xc:$background" png24:background.png
composite -gravity center $1 background.png $outputFilename

[ -f background.png ] && rm background.png
