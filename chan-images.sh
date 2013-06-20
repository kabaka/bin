#!/bin/zsh

cd /tmp

if [ $# -eq 1 ]; then

  TEMPFILE=`mktemp`
  TEMPLIST=`mktemp`

  wget "$1" -O$TEMPFILE

  BASEURL=`dirname "$1"`

  egrep -o "http://[^ \"]+\.(jpg|jpeg|png|gif|bmp|svg|mjpeg|mjpg)" $TEMPFILE > $TEMPLIST
  egrep -o "\"[^ \"]+\.(jpg|jpeg|png|gif|bmp|svg|mjpeg|mjpg)" $TEMPFILE | grep -v "http" | cut -d"\"" -f2- | awk -v URL=${BASEURL} '{ printf "%s/%s\n", URL, $1; }' >> $TEMPLIST


  SORTTEMP=`mktemp`

  sort -u $TEMPLIST | grep -v ".+s\..+" > $SORTTEMP
  rm $TEMPLIST

  aria2c -x4 -i$SORTTEMP --conditional-get=true --allow-overwrite=true -d ~/downloads/scraper/`echo $1 | cut -d"/" -f3`


  rm $TEMPFILE $SORTTEMP
else
  echo "Usage: $0 <url> <extension>"
fi
