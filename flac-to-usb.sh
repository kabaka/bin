#!/bin/zsh

if [ $# -ne 1 ] ; then
  echo "Usage: $0 DIR"
  exit -1
fi

TMPDIR=`mktemp -d -p /dev/shm`
DIR=$1
COUNTER=0
THREADS=4

cd $DIR

mkdir "/$TMPDIR/$DIR/"

function reaper() {
  COUNTER=`expr $COUNTER - 1`
}

function spawn() {
  while [ $COUNTER -eq $THREADS ]; do
    sleep 1
  done

  COUNTER=`expr $COUNTER + 1`

  NEWNAME=`echo "$1" | sed -r "s/\.flac$/.mp3/"`
  flac -d "$1" -c | lame --alt-preset insane - "/$TMPDIR/$DIR/$NEWNAME" &
}

trap "reaper" CHLD

for f in *.flac; do
  spawn $f
done

wait

mv "/$TMPDIR/$DIR/" "/mnt/usb/" && rm -rf "/$TMPDIR/"
