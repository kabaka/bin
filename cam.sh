#!/bin/bash

FILENAME="cam_`date +%m%d%Y_%H%M%S%N`.jpeg"

v4l2-ctl -c brightness=255

streamer -q -o now.ppm 2> /dev/null && convert \
  -pointsize 15 -fill white -stroke black \
  -brightness-contrast 5x5  \
  -draw "text 15,225 '`date`'" -draw "text 225,15 'Kabaka Cam'" \
  now.ppm $FILENAME && rm now.ppm && ~/scripts/imgup.sh "$FILENAME" && rm "$FILENAME"

