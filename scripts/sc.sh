#!/bin/bash

sclink=""
outputFilename=""
title=""
artist=""
album=""
cover=""

while getopts l:o:t:r:b:c:f flag; do
  case "${flag}" in
    l) sclink="${OPTARG}";;
    o) outputFilename="${OPTARG}";;
    t) title="${OPTARG}";;
    r) artist="${OPTARG}";;
    b) album="${OPTARG}";;
    c) cover="${OPTARG}";;
  esac
done

if [ -z "$sclink" ]
  then
    echo "No soundcloud link is passed! Exiting..."
    exit 1
fi

if [ -z "$outputFilename" ]
  then
    echo "Output filename is required! Exiting..."
    exit 1
fi

metadataFile="metadata.json"
youtube-dl "$sclink" --add-metadata --print-json > "$metadataFile"

tempFilename=$(jq -r "._filename" "$metadataFile")
outputExt=$(jq -r ".ext" "$metadataFile")
outputFilename="$outputFilename.mp3"
tempFileNameConvert="t.mp3"
args=("-i" "$tempFilename")

thumbnail=$(echo $(jq ".thumbnail" "$metadataFile") | sed 's/\"//g')
original=$(echo $thumbnail | sed 's/t500x500/original/g')

wget -qO thumbnailCover "$thumbnail"
wget -qO originalCover "$original"

cover=thumbnailCover

if [ -f originalCover ]
  then
    originalWidth=$(identify -format '%w' originalCover)
    if [ "$originalWidth" -gt 500 ]
      then
        rm thumbnailCover
        cover=originalCover

        if [ "$originalWidth" -gt 3000 ]
          then
            convert -debug None originalCover -resize 3000x3000 originalCover
        fi
    fi
fi

args+=("-i" "$cover" "-map" "0:0" "-map" "1:0" "-c" "copy" "-id3v2_version" "3" "-metadata:s:v" "title=Album Cover" "-metadata:s:v" "comment=Cover (front)")

if ! [ -z "$title" ]
  then
    args+=("-metadata" "title=$title")
fi

if ! [ -z "$artist" ]
  then
    args+=("-metadata" "artist=$artist" "-metadata" "album_artist=$artist")
fi

if ! [ -z "$album" ]
  then
    args+=("-metadata" "album=$album")
fi

args+=("-metadata" "comment=Source: $sclink")

if [ "$outputExt" != "mp3" ]
  then
    ffmpeg -loglevel quiet -i "$tempFilename" -ab 320k "$tempFileNameConvert"
    args[1]="$tempFileNameConvert"
fi

ffmpeg -loglevel quiet "${args[@]}" -acodec copy "$outputFilename"

[ -f $tempFileNameConvert ] && rm $tempFileNameConvert
[ -f "$tempFilename" ] && rm "$tempFilename"
[ -f "$metadataFile" ] && rm "$metadataFile"
[ -f thumbnailCover ] && rm thumbnailCover
[ -f originalCover ] && rm originalCover
