#!/bin/bash

cp "$1" "temp.mp3"
rm "$1"
ffmpeg -loglevel quiet -i "temp.mp3" -i "$2" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$1"
rm "temp.mp3"
