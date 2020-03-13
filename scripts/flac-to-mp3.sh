#!/bin/bash

# Source: https://stackoverflow.com/questions/26109837/convert-flac-to-mp3-with-ffmpeg-keeping-all-metadata

ffmpeg -i "$1" -ab 320k -map_metadata 0 -id3v2_version 3 "$2"
