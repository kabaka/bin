#!/bin/zsh

if [ $# -ne 2 ]; then
  echo "Usage: ${0} start_image query"
  echo ""
  echo "Note: query is not escaped or URL encoded"
  exit 1
fi

TEMPFILE=`mktemp`
TEMPLIST=`mktemp`

curl -q "http://wallbase.cc/search/$1?q=$2" | grep -Eo "http://wallbase.cc/wallpaper/[0-9]+" >> $TEMPFILE

for line in $(< $TEMPFILE); do 
  echo "Line: $line"
  curl -q "$line" | tee | grep -E 'class="wall stage1' | grep -Eo "http://[^\"]+" >> $TEMPLIST
done

rm $TEMPFILE

SORTTEMP=`mktemp`

sort -u $TEMPLIST > $SORTTEMP

rm $TEMPLIST

cat $SORTTEMP

aria2c -i$SORTTEMP -x1 -j1 --retry-wait=60 -m10 -d ~/downloads/wallbase/`echo "$1" | sed -r "s/[^A-Za-z]/_/g"`/

rm $SORTTEMP

