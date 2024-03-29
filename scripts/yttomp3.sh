#!/bin/bash

ytlink=""
outputFileName=""
title=""
artist=""
album=""
cover=""
start="0"
end="0"

while getopts l:o:t:r:b:c:s:e: flag; do
  case "${flag}" in
    l) ytlink="${OPTARG}";;
    o) outputFileName="${OPTARG}";;
    t) title="${OPTARG}";;
    r) artist="${OPTARG}";;
    b) album="${OPTARG}";;
    c) cover="${OPTARG}";;
    s) start="${OPTARG}";;
    e) end="${OPTARG}";;
  esac
done

[ -z "$ytlink" ] && echo "No youtube link is passed! Exiting..." && exit
[ -z "$outputFileName" ] && echo "Output filename is required! Exiting..." && exit

baseFolderOutput=$(jq -r ".baseFolderOutput" "$configJson")

if [ "$baseFolderOutput" == "null" ]; then
  baseFolderOutput="$HOME"
fi

youtube-dl "$ytlink" --add-metadata --extract-audio --audio-format mp3 --output "temp.%(ext)s"

tempFilename="temp.mp3"
mp3OutputFileName="$baseFolderOutput/$outputFileName.mp3"
args=("-i" "$tempFilename")
ytthumbtac="$HOME/doscricon/scripts/ytthumb-to-album-cover.sh"

if [ "$start" != "0" ] || [ "$end" != "0" ]
  then
    # somehow if trimming and adding cover is included on param...
    # the output file has no cover...idk the reason :(
    # this part separates the trimming function and now it works!
    toTrimFileName="totrim.mp3"
    cp "$tempFilename" "$toTrimFileName"
    rm "$tempFilename"

    # do not add `-to` arg if -e arg is not passed
    trimArgs=("-i" "$toTrimFileName" "-ss" "$start")
    if [ "$end" != "0" ]; then
      trimArgs+=("-to" "$end")
    fi

    ffmpeg -loglevel quiet "${trimArgs[@]}" -acodec copy "$tempFilename"
    rm "$toTrimFileName"
fi

if ! [ -z "$cover" ]; then
  if ! [[ "$cover" =~ "." ]] # 
    then
      sh $ytthumbtac $ytlink "$outputFileName" "$cover"
      cover="$outputFileName.png" # expects that ytthumbtac will always result to png
  fi
  args+=("-i" "$cover" "-map" "0:0" "-map" "1:0" "-c" "copy" "-id3v2_version" "3" "-metadata:s:v" "title=Album Cover" "-metadata:s:v" "comment=Cover (front)")
fi

! [ -z "$title" ] && args+=("-metadata" "title=$title")
! [ -z "$artist" ] && args+=("-metadata" "artist=$artist" "-metadata" "album_artist=$artist")
! [ -z "$album" ] && args+=("-metadata" "album=$album")

args+=("-metadata" "comment=Source: $ytlink")

ffmpeg -loglevel quiet "${args[@]}" -acodec copy "$mp3OutputFileName"

[ -f "$cover" ] && rm "$cover"
[ -f "$tempFilename" ] && rm "$tempFilename"
