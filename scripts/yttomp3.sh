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

if [ -z "$ytlink" ]
  then
    echo "No youtube link is passed! Exiting..."
    exit 1
fi

if [ -z "$outputFileName" ]
  then
    echo "Output filename is required! Exiting..."
    exit 1
fi

youtube-dl "$ytlink" --add-metadata --extract-audio --audio-format mp3 --output "temp.%(ext)s"

tempFilename="temp.mp3"
outputFileName="$outputFileName.mp3"
args=("-i" "$tempFilename")

if [ "$start" != "0" ] || [ "$end" != "0" ]
  then
    # somehow if trimming and adding cover is included on param...
    # the output file has no cover...idk the reason :(
    # this part separates the trimming function and now it works!
    toTrimFileName="totrim.mp3"
    cp "$tempFilename" "$toTrimFileName"
    rm "$tempFilename"
    ffmpeg -loglevel quiet -i "$toTrimFileName" -ss "$start" -to "$end" -acodec copy "$tempFilename"
    rm "$toTrimFileName"
fi

metadataFile="metadata.json"
if ! [ -z "$cover" ]; then
  youtube-dl "$ytlink" --add-metadata --print-json --skip-download > "$metadataFile"
  thumbnailLink=$(echo $(jq ".thumbnail" "$metadataFile") | sed 's/hqdefault/maxresdefault/g' | sed 's/\"//g')
  wget -qO "rawcover.jpg" "$thumbnailLink"

  if [ "$cover" = "center" ]
    then
      echo "[ffmpeg] Embedding youtube thumbnail center as cover art on track..."
      convert "rawcover.jpg" -crop 720x720+280+0 coverart.png
    else
      echo "[ffmpeg] Embedding youtube thumbnail as cover art on track..."
      convert -size 1280x1280 xc:transparent png24:transparent.png
      composite -gravity center rawcover.jpg transparent.png coverart.png
      rm transparent.png
  fi
fi

cover="coverart.png"
args+=("-i" "$cover" "-map" "0:0" "-map" "1:0" "-c" "copy" "-id3v2_version" "3" "-metadata:s:v" "title=Album Cover" "-metadata:s:v" "comment=Cover (front)")

args+=("-metadata" "title=$title" "-metadata" "artist=$artist" "-metadata" "album=$album" "-metadata" "comment=Source: $ytlink")
ffmpeg -loglevel quiet "${args[@]}" -acodec copy "$outputFileName"

[ -f "$cover" ] && rm "$cover"
[ -f rawcover.jpg ] && rm rawcover.jpg
[ -f "$metadataFile" ] && rm "$metadataFile"
[ -f "$tempFilename" ] && rm "$tempFilename"
