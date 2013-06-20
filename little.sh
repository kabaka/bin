#!/bin/bash

DIR="small"
DIRNEW="small"
DIRINT=1
IMGCOUNT=0

while [ -d $DIRNEW ]
do
  DIRNEW=$DIR$DIRINT
  DIRINT=$(( $DIRINT + 1 ))
done

DIR=$DIRNEW

mkdir "$DIR"

for i in *.$1;
do
  while [ `ps --no-headers -C convert | wc -l` == "2" ];
  do
    sleep 0.5;
  done;

  convert -resize "$2" "$i" "$DIR/$i" &
  #convert -border $3 -bordercolor "#FFFFFF" -resize "$2" "$i" "$DIR/$i" &
  IMGCOUNT=$(( $IMGCOUNT+1 ))
done

echo "Resized $IMGCOUNT *.$1 files to $2 into $DIR"

