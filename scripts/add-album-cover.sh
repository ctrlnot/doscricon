#!/bin/sh

[ -z "$1" ] || [ -z "$2" ] && echo "Please input track and cover source!" && exit
! [ -f "$2" ] && echo "Cover source does not exists!" && exit

# required to use the absolute path because
# while looping on embedDirFunc and executing the ffmpeg...
# some of the next files first character in path will be stripped off (i know wtf...)
# so, I required the paths to be passed is absolute so that I can predict the first character
# which is slash
! [[ "$1" = /* ]] && echo "Please input absolute path!" && exit

embedFunc () {
  echo "Embedding $2 to $1..."

  cp "$1" "temp.mp3"
  rm "$1"
  ffmpeg -loglevel quiet -y -i "temp.mp3" -i "$2" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$1"
  rm "temp.mp3"
}

embedDirFunc () {
  find "$1" -name "*.mp3" | while read track; do
    case "$track" in
      /*) embedFunc "$track" "$2" ;;
      *) embedFunc "/$track" "$2" ;; # add slash if missing
    esac
  done
}

isDir=$([ -d "$1" ] && echo "1")

case "$isDir" in
  "1") embedDirFunc "$1" "$2" ;;
  *) embedFunc "$1" "$2" ;;
esac
