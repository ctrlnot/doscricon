#!/bin/sh

echo "[ptac] Reformatting source pic..."

center () {
  extension="${1##*.}"
  filename=$(basename "$1" ".$extension")

  width=$(identify -format '%w' "$1")
  height=$(identify -format '%h' "$1")
  isLandscape=$([ $width -gt $height ] && echo "1" || echo "0")

  offset=""

  if [ $isLandscape = "1" ]
    then
      offset=$((width - height))
      offset=$((offset / 2))
      offset="${height}x${height}+${offset}+0"
    else
      offset=$((height - width))
      offset=$((offset / 2))
      offset="${width}x${width}+0+${offset}"
  fi

  convert "$1" -crop "$offset" "$filename.png"
  rm "$1"
}

fit () {
  background=$2
  extension="${1##*.}"
  filename=$(basename "$1" ".$extension")

  [ "$2" != "transparent" ] && ! [[ "$2" =~ ^[0-9A-Fa-f]{6}$ ]] && echo "Invalid hex value! $2" && exit
  [ "$2" != "transparent" ] && background="#$2"

  picWidth=$(identify -format '%w' "$1")

  convert -size "${picWidth}x${picWidth}" "xc:$background" png24:background.png
  composite -gravity center "$1" background.png "$filename.png"

  rm "$1"
  [ -f background.png ] && rm background.png
}

case "$2" in
  "center") center "$1" "$2" ;;
  *) fit "$1" "$2" ;;
esac
