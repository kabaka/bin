#!/bin/zsh

if [ $# -eq 2 ]; then

  TEMPFILE=`mktemp`
  TEMPLIST=`mktemp`

  curl -q "http://wallbase.cc/search/_$1_/0/eqeq/0x0/0/110/60/relevance/wallpapers/$2" | egrep -o "http://wallbase.cc/wallpaper/[0-9]+" >> $TEMPFILE
  
  for line in $(< $TEMPFILE); do 
    echo "Line: $line"
    curl -q "$line" | tee | egrep -A 3 "bigwall" | egrep -o "http://[^ \"']+" >> $TEMPLIST
  done

  rm $TEMPFILE

  SORTTEMP=`mktemp`

  sort -u $TEMPLIST > $SORTTEMP
  
  rm $TEMPLIST

  cat $SORTTEMP

  aria2c -i$SORTTEMP -x1 -j1 --retry-wait=60 -m10 -d ~/downloads/wallbase/`echo "$1" | sed -r "s/[^A-Za-z]/_/g"`/

  rm $SORTTEMP
fi

