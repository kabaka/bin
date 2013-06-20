#!/bin/zsh

cd /tmp

if [ $# -eq 2 ]; then

  TEMPFILE=`mktemp`
  TEMPLIST=`mktemp`

  wget "$1" -O$TEMPFILE

  #cat $TEMPFILE

  echo

  BASEURL=`dirname "$1"`
  DOMAIN=`echo "$1" | cut -d"/" -f3`

  egrep -o "http://[^ \"]+\.$2" $TEMPFILE > $TEMPLIST
  egrep -o "\"[^ \"]+\.$2" $TEMPFILE | cut -d"\"" -f2- | awk -v DOMAIN=${DOMAIN} -v URL=${BASEURL} '{ if(index($1, "/") == 1) { printf "http://%s/%s\n", DOMAIN, $1;} else { printf "%s/%s\n", URL, $1 } }' >> $TEMPLIST

  SORTTEMP=`mktemp`

  sort -u $TEMPLIST > $SORTTEMP
  rm $TEMPLIST

  aria2c -U 'Mozilla/5.0 (X11; Linux x86_64; rv:7.0) Gecko/20100101 Firefox/7.0' --referer "$1" -x4 -i$SORTTEMP -d ~/downloads/scraper/`echo $1 | cut -d"/" -f3`
  #wget -U 'Mozilla/5.0 (X11; Linux x86_64; rv:7.0) Gecko/20100101 Firefox/7.0' --referer "$1" -i $SORTTEMP -P ~/downloads/scraper/`echo $1 | cut -d"/" -f3`


  rm $TEMPFILE $SORTTEMP
else
  echo "Usage: $0 <url> <extension>"
fi
