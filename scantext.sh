#!/bin/zsh

if [[ $1 == "" ]]; then
  echo "Usage: $0 filename [clean]"
  exit
fi

scanimage --format=tiff --resolution 200dpi > "$1.tiff"
tesseract "$1.tiff" "$1" &> /dev/null
cat "$1.txt"

if [[ $2 == "clean" ]]; then
  rm "$1.tiff" "$1.txt"
fi

