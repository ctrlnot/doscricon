#!/bin/bash

ytLink=$1
isPlaylist=$2 # always assume by default that link is meant not to be playlist

if [ -z "$ytLink" ]; then
  echo "No youtube link is passed! Exiting..."
  exit 1
fi

configJson="$HOME/doscricon/config.json"
[ -z "config.json" ] && echo "Config not found... using default values..."

baseFolderOutput=$(jq -r ".baseFolderOutput" "$configJson")

if [ "$baseFolderOutput" == "null" ]; then
  baseFolderOutput="$HOME"
fi

args=(
  "--add-metadata"
  "--write-info-json"
  "--no-continue"
  "--download-archive" "~/archive.log"
  "-i" "--all-subs" "--embed-subs" "--embed-thumbnail"
  "-f" "(bestvideo[vcodec^=avc1][height>=1080][fps>30]/bestvideo[vcodec=vp9.2][height>=1080][fps>30]/bestvideo[vcodec=vp9][height>=1080][fps>30]/bestvideo[vcodec^=av01][height>=1080]/bestvideo[vcodec=vp9.2][height>=1080]/bestvideo[vcodec=vp9][height>=1080]/bestvideo[height>=1080]/bestvideo[vcodec^=av01][height>=720][fps>30]/bestvideo[vcodec=vp9.2][height>=720][fps>30]/bestvideo[vcodec=vp9][height>=720][fps>30]/bestvideo[vcodec^=av01][height>=720]/bestvideo[vcodec=vp9.2][height>=720]/bestvideo[vcodec=vp9][height>=720]/bestvideo[height>=720]/bestvideo)+(bestaudio[acodec=opus]/bestaudio)/best"
  "--merge-output-format" "mkv"
)

if [ "$isPlaylist" == "true" ]
  then
    args+=("-o" "$baseFolderOutput/%(playlist_uploader)s/%(playlist)s/%(playlist_index)s - %(title)s - %(id)s.%(ext)s")
  else
    args+=(
      "--no-playlist"
      "-o" "$baseFolderOutput/%(uploader)s/%(title)s - %(id)s.%(ext)s"
    )
fi

youtube-dl "${args[@]}" "$ytLink"
